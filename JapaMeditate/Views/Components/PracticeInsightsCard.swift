import SwiftUI

struct PracticeInsightsCard: View {
    let valuesByDate: [String: Int]
    let metricName: String
    let metricPluralName: String
    let bestDayLabel: String
    let averageLabel: String
    let consistencyLabel: String
    let emptyMessage: String
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "sparkles")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            if hasPractice {
                VStack(spacing: 10) {
                    InsightRow(label: bestDayLabel, value: bestDayText)
                    InsightRow(label: averageLabel, value: averageText)
                    InsightRow(label: consistencyLabel, value: consistencyText)
                }
            } else {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.92))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

private extension PracticeInsightsCard {
    var practiceDays: [PracticeInsightDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = dateKeyFormatter

        return (0..<30).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - 29, to: today) else {
                return nil
            }

            let key = formatter.string(from: date)
            return PracticeInsightDay(date: date, value: valuesByDate[key, default: 0])
        }
    }

    var hasPractice: Bool {
        totalValue > 0
    }

    var activeDays: Int {
        practiceDays.filter { $0.value > 0 }.count
    }

    var totalValue: Int {
        practiceDays.reduce(0) { $0 + $1.value }
    }

    var bestDayText: String {
        guard let bestDay = practiceDays.max(by: { $0.value < $1.value }), bestDay.value > 0 else {
            return "No practice yet"
        }

        let label = bestDay.value == 1 ? metricName : metricPluralName
        return "\(shortDisplayFormatter.string(from: bestDay.date)) • \(bestDay.value) \(label)"
    }

    var averageText: String {
        let average = Double(totalValue) / 30.0
        return "\(formatAverage(average)) \(metricPluralName) per day"
    }

    var consistencyText: String {
        "\(activeDays) of 30 active days"
    }

    var dateKeyFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }

    var shortDisplayFormatter: DateFormatter {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMM d")
        return f
    }

    func formatAverage(_ value: Double) -> String {
        if value >= 10 || value.rounded() == value {
            return String(format: "%.0f", value)
        }

        return String(format: "%.1f", value)
    }
}

private struct PracticeInsightDay {
    let date: Date
    let value: Int
}

private struct InsightRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.86))
                .frame(width: 96, alignment: .leading)

            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
