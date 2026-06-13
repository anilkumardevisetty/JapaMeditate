import SwiftUI

struct MeditationStatsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @State private var stats: JapaStats = JapaStatsManager.shared.load()

    // 3 equal columns for tiles
    private let statColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                AppPanel {
                    VStack(spacing: 16) {
                        headerTile
                        todayCard
                        weeklySummaryCard
                        practiceCalendarCard
                        insightsCard
                        milestonesCard
                        StyledBanner()
                        lifetimeCard
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Meditation Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            stats = JapaStatsManager.shared.load()
            AnalyticsManager.shared.log(.meditationStatsViewed)
        }
    }
}

// MARK: - Sections
private extension MeditationStatsView {

    var headerTile: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Meditation Stats")
                .font(.title.bold())
                .foregroundColor(.white)

            Text("Track your breathing practice over time.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var todayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(todayDisplayDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }

            LazyVGrid(columns: statColumns, spacing: 10) {
                MeditationStatTile(label: "Sessions", value: "\(todaySessions)")
                MeditationStatTile(label: "Minutes", value: "\(todayMinutes)")
                MeditationStatTile(label: "Total Sessions", value: "\(stats.lifetimeMeditationSessions)")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var lifetimeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lifetime")
                .font(.headline)
                .foregroundColor(.white)

            LifetimeRow(label: "Total Minutes", value: "\(stats.lifetimeMeditationMinutes)")
            LifetimeRow(label: "Total Sessions", value: "\(stats.lifetimeMeditationSessions)")
            LifetimeRow(label: "Last Session", value: lastMeditationString)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var practiceCalendarCard: some View {
        PracticeCalendarCard(
            title: "Last 30 Days",
            valuesByDate: stats.dailyMeditationMinutes,
            metricName: "minute",
            metricPluralName: "minutes",
            theme: selectedTheme,
            intensityLevel: meditationIntensityLevel
        )
    }

    var weeklySummaryCard: some View {
        WeeklySummaryCard(
            valuesByDate: stats.dailyMeditationMinutes,
            metricName: "minute",
            metricPluralName: "minutes",
            theme: selectedTheme
        )
    }

    var insightsCard: some View {
        PracticeInsightsCard(
            valuesByDate: stats.dailyMeditationMinutes,
            metricName: "minute",
            metricPluralName: "minutes",
            bestDayLabel: "Longest day",
            averageLabel: "Daily average",
            consistencyLabel: "Consistency",
            emptyMessage: "Finish a meditation session to unlock your first meditation insight.",
            theme: selectedTheme
        )
    }

    var milestonesCard: some View {
        MilestoneBadgesCard(
            title: "Milestones",
            milestones: meditationMilestones,
            theme: selectedTheme
        )
    }
}

// MARK: - Helpers
private extension MeditationStatsView {

    var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    var todaySessions: Int {
        stats.dailyMeditationSessions[todayKey, default: 0]
    }

    var todayMinutes: Int {
        stats.dailyMeditationMinutes[todayKey, default: 0]
    }

    var todayDisplayDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }

    var lastMeditationString: String {
        guard let date = stats.lastMeditationDate else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    func meditationIntensityLevel(minutes: Int) -> Int {
        switch minutes {
        case 0:
            return 0
        case 1..<10:
            return 1
        case 10..<20:
            return 2
        default:
            return 3
        }
    }

    var meditationMilestones: [PracticeMilestone] {
        [
            PracticeMilestone(
                id: "first-session",
                title: "First Session",
                subtitle: stats.lifetimeMeditationSessions >= 1 ? "You created space to sit" : "Complete 1 session",
                systemImage: "play.circle.fill",
                isUnlocked: stats.lifetimeMeditationSessions >= 1
            ),
            PracticeMilestone(
                id: "seven-active-days",
                title: "7 Active Days",
                subtitle: "\(activeMeditationDays) days recorded",
                systemImage: "calendar.badge.checkmark",
                isUnlocked: activeMeditationDays >= 7
            ),
            PracticeMilestone(
                id: "hundred-minutes",
                title: "100 Minutes",
                subtitle: "\(stats.lifetimeMeditationMinutes) lifetime minutes",
                systemImage: "clock.fill",
                isUnlocked: stats.lifetimeMeditationMinutes >= 100
            ),
            PracticeMilestone(
                id: "ten-sessions",
                title: "10 Sessions",
                subtitle: "\(stats.lifetimeMeditationSessions) sessions completed",
                systemImage: "leaf.fill",
                isUnlocked: stats.lifetimeMeditationSessions >= 10
            )
        ]
    }

    var activeMeditationDays: Int {
        stats.dailyMeditationMinutes.values.filter { $0 > 0 }.count
    }
}

// MARK: - Inner tiles (3 equal tiles inside Today)
struct MeditationStatTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.center)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(Color.white.opacity(0.18))
        .cornerRadius(16)
    }
}

// MARK: - Lifetime row label/value
struct LifetimeRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}

struct MeditationStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MeditationStatsView()
        }
    }
}
