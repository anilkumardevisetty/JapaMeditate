import SwiftUI

struct PracticeCalendarCard: View {
    let title: String
    let valuesByDate: [String: Int]
    let metricName: String
    let metricPluralName: String
    let theme: AppTheme
    var intensityLevel: (Int) -> Int = { value in
        switch value {
        case 0:
            return 0
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 3
        }
    }

    private var calendarColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(summaryText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "calendar")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            LazyVGrid(columns: calendarColumns, spacing: 8) {
                ForEach(calendarDays) { day in
                    PracticeDayCell(day: day)
                }
            }

            HStack(spacing: 10) {
                Text("Less")
                ForEach(0..<4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(PracticeDayCell.backgroundColor(for: level))
                        .frame(width: 16, height: 16)
                }
                Text("More")
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.85))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

private extension PracticeCalendarCard {
    var calendarDays: [PracticeDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = dateKeyFormatter
        let displayFormatter = shortDisplayFormatter

        return (0..<30).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - 29, to: today) else {
                return nil
            }

            let key = formatter.string(from: date)
            let value = valuesByDate[key, default: 0]
            let label = value == 1 ? metricName : metricPluralName

            return PracticeDay(
                id: key,
                dayNumber: calendar.component(.day, from: date),
                accessibilityLabel: "\(displayFormatter.string(from: date)): \(value) \(label)",
                value: value,
                intensity: intensityLevel(value)
            )
        }
    }

    var summaryText: String {
        let activeDays = calendarDays.filter { $0.value > 0 }.count
        let total = calendarDays.reduce(0) { $0 + $1.value }
        let label = total == 1 ? metricName : metricPluralName
        return "\(activeDays) active days • \(total) \(label)"
    }

    var dateKeyFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }

    var shortDisplayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }
}

private struct PracticeDay: Identifiable {
    let id: String
    let dayNumber: Int
    let accessibilityLabel: String
    let value: Int
    let intensity: Int
}

private struct PracticeDayCell: View {
    let day: PracticeDay

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.white.opacity(day.value > 0 ? 0.35 : 0.08), lineWidth: 1)
                )

            Text("\(day.dayNumber)")
                .font(.caption2.weight(.semibold))
                .foregroundColor(day.value > 0 ? .black.opacity(0.78) : .white.opacity(0.72))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(day.accessibilityLabel)
    }

    private var backgroundColor: Color {
        Self.backgroundColor(for: day.intensity)
    }

    static func backgroundColor(for intensity: Int) -> Color {
        switch intensity {
        case 0:
            return Color.white.opacity(0.16)
        case 1:
            return Color.white.opacity(0.38)
        case 2:
            return Color.white.opacity(0.64)
        default:
            return Color.white.opacity(0.95)
        }
    }
}
