import SwiftUI

struct WeeklySummaryCard: View {
    let valuesByDate: [String: Int]
    let metricName: String
    let metricPluralName: String
    let theme: AppTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Summary")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(trendText)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: trendIcon)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 10) {
                WeeklySummaryStatTile(
                    label: "This week",
                    value: "\(thisWeekTotal)",
                    detail: metricLabel(for: thisWeekTotal)
                )

                WeeklySummaryStatTile(
                    label: "Last week",
                    value: "\(lastWeekTotal)",
                    detail: metricLabel(for: lastWeekTotal)
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

private extension WeeklySummaryCard {
    var thisWeekTotal: Int {
        total(fromDaysAgo: 0..<7)
    }

    var lastWeekTotal: Int {
        total(fromDaysAgo: 7..<14)
    }

    var difference: Int {
        thisWeekTotal - lastWeekTotal
    }

    var trendText: String {
        if difference > 0 {
            return "Up \(difference) \(metricLabel(for: difference)) from last week"
        }

        if difference < 0 {
            let decrease = abs(difference)
            return "Down \(decrease) \(metricLabel(for: decrease)) from last week"
        }

        if thisWeekTotal == 0 {
            return "Start this week with one small session"
        }

        return "Same as last week"
    }

    var trendIcon: String {
        if difference > 0 {
            return "arrow.up.right.circle.fill"
        }

        if difference < 0 {
            return "arrow.down.right.circle.fill"
        }

        return "minus.circle.fill"
    }

    func total(fromDaysAgo range: Range<Int>) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = dateKeyFormatter

        return range.reduce(0) { total, daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return total
            }

            return total + valuesByDate[formatter.string(from: date), default: 0]
        }
    }

    func metricLabel(for value: Int) -> String {
        value == 1 ? metricName : metricPluralName
    }

    var dateKeyFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }
}

private struct WeeklySummaryStatTile: View {
    let label: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.86))

            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(detail)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background(Color.white.opacity(0.18))
        .cornerRadius(16)
    }
}
