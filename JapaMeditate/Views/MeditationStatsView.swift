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

    /// Note: you currently store lifetimeMeditationMinutes, not per-day minutes.
    /// So this reflects the same value you showed on HomeView.
    var todayMinutes: Int {
        stats.lifetimeMeditationMinutes
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
