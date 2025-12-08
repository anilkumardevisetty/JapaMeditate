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
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Header tile (same style as hero card)
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

                    // MARK: - Today (theme gradient card with 3 equal tiles)
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
                            MeditationStatTile(
                                label: "Sessions",
                                value: "\(todaySessions)"
                            )

                            MeditationStatTile(
                                label: "Minutes",
                                // ✅ same technique as HomeView
                                // uses stats.lifetimeMeditationMinutes (not *5)
                                value: "\(todayMinutes)"
                            )

                            MeditationStatTile(
                                label: "Total Sessions",
                                value: "\(stats.lifetimeMeditationSessions)"
                            )
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTheme.background)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                    // MARK: - Ad banner (already themed on Home)
                    StyledBanner() // 👈 looks like part of the UI

                    // MARK: - Lifetime Card (theme gradient, like Today’s Highlights)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lifetime")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            LifetimeRow(label: "Total Minutes",
                                        value: "\(stats.lifetimeMeditationMinutes)")
                            Spacer()
                        }

                        HStack {
                            LifetimeRow(label: "Total Sessions",
                                        value: "\(stats.lifetimeMeditationSessions)")
                            Spacer()
                        }

                        HStack {
                            LifetimeRow(label: "Last Session",
                                        value: lastMeditationString)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTheme.background)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Meditation Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            stats = JapaStatsManager.shared.load()
        }
    }

    // MARK: - Helpers

    private var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private var todaySessions: Int {
        stats.dailyMeditationSessions[todayKey, default: 0]
    }

    /// ✅ Use same technique as HomeView: use lifetimeMeditationMinutes
    /// (since that's what you already trust & see as correct).
    private var todayMinutes: Int {
        stats.lifetimeMeditationMinutes
    }

    private var todayDisplayDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }

    private var lastMeditationString: String {
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
        .frame(maxWidth: .infinity, minHeight: 72)   // ✅ equal width & height
        .background(Color.white.opacity(0.18))       // same as HighlightStatCard
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
