import SwiftUI
import Combine

struct HomeView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @AppStorage("userName") private var userName: String = ""

    @State private var stats: JapaStats = JapaStatsManager.shared.load()
    @State private var motivation: String = ""

    private let motivationQuotes = [
        "One mantra can transform your entire day.",
        "Every breath is a chance to return to peace.",
        "Stillness begins with a single chant.",
        "Meditation is food for the soul.",
        "A calm mind is the greatest spiritual gift.",
        "Repeat softly, feel deeply, awaken gently.",
        "Consistency brings spiritual strength.",
        "Your practice today shapes your peace tomorrow."
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                GeometryReader { geo in
                    let isCompact = geo.size.height < 700

                    AppPanel {
                        VStack(spacing: isCompact ? 14 : 20) {
                            heroCard(isCompact: isCompact)
                            primaryActionsRow
                            highlightsCard
                            motivationQuote
                            toolsRow
                            adBannerTile
                            Spacer(minLength: isCompact ? 8 : 12)
                            footerQuote
                        }
                    }
                }
            }
        }
        .onAppear {
            stats = JapaStatsManager.shared.load()
            motivation = motivationQuotes.randomElement() ?? ""
        }
    }
}

// MARK: - Sections
private extension HomeView {

    func heroCard(isCompact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("JapaMeditate")
                    .font(.caption2.smallCaps())
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                if stats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                        Text("\(stats.currentStreak)d")
                            .font(.caption.bold())
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(14)
                    .foregroundColor(.white)
                }
            }

            Text(greetingTitle())
                .font(.system(size: isCompact ? 18 : 20, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.8)

            Text("Cultivate a steady mantra & meditation habit.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.95))

            HStack(spacing: 6) {
                Image(systemName: "calendar").font(.caption2)
                Text(formattedDayString()).font(.caption2)
                Text("•").font(.caption2)
                Image(systemName: "clock").font(.caption2)
                ClockView().font(.caption2)
            }
            .foregroundColor(.white.opacity(0.95))
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
        .padding(.top, isCompact ? 6 : 10)
    }

    var primaryActionsRow: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: CounterView()) {
                PrimaryActionTile(
                    icon: "circle.dotted",
                    title: "Japam",
                    background: selectedTheme.background
                )
            }

            NavigationLink(destination: MeditationView()) {
                PrimaryActionTile(
                    icon: "figure.mind.and.body",
                    title: "Meditate",
                    background: selectedTheme.background
                )
            }
        }
    }

    var highlightsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today’s Highlights")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: StatsView()) {
                    Text("Japa")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }

                NavigationLink(destination: MeditationStatsView()) {
                    Text("Meditation")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }

            HStack(spacing: 12) {
                HighlightStatCard(label: "Japa Rounds", value: "\(todayRounds())")
                HighlightStatCard(label: "Meditation Mins", value: "\(stats.lifetimeMeditationMinutes)")
            }
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var motivationQuote: some View {
        Group {
            if !motivation.isEmpty {
                Text("“\(motivation)”")
                    .font(.footnote)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
            }
        }
    }

    var toolsRow: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: ThemeView()) {
                SecondaryActionTile(
                    icon: "paintpalette.fill",
                    title: "Themes",
                    background: selectedTheme.background
                )
            }

            NavigationLink(destination: SettingsView()) {
                SecondaryActionTile(
                    icon: "gearshape.fill",
                    title: "Settings",
                    background: selectedTheme.background
                )
            }
        }
    }

    var adBannerTile: some View {
        AdBannerTile(background: selectedTheme.background)
    }

    var footerQuote: some View {
        Text("“Chanting purifies the mind & uplifts the soul.”")
            .font(.footnote)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .padding(.bottom, 4)
    }
}

// MARK: - Helpers
private extension HomeView {

    func todayRounds() -> Int {
        let today = formattedDate(Date())
        return stats.dailyRounds[today, default: 0]
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func formattedDayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · MMM d"
        return f.string(from: Date())
    }

    func greetingBase() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default:      return "Good Day"
        }
    }

    func greetingTitle() -> String {
        let base = greetingBase()
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? base : "\(base), \(trimmed)"
    }
}

// MARK: - Primary action tile (Japa / Meditate)

struct PrimaryActionTile: View {
    let icon: String
    let title: String
    let background: LinearGradient

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.headline.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 72)
        .padding(.horizontal, 12)
        .background(background)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }
}

struct SecondaryActionTile: View {
    let icon: String
    let title: String
    let background: LinearGradient

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
            Text(title)
                .font(.subheadline.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding(.horizontal, 10)
        .background(background)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }
}

// MARK: - Highlight Stat Card

struct HighlightStatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(10)
        .frame(minHeight: 72)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.18))
        .cornerRadius(16)
    }
}

// MARK: - Ad Banner Tile

struct AdBannerTile: View {
    let background: LinearGradient

    var body: some View {
        VStack(spacing: 6) {
            Text("Sponsored")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))

            BannerAdView()
                .frame(maxWidth: .infinity)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(background)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
    }
}
