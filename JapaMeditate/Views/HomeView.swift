import SwiftUI
import Combine
import StoreKit

struct HomeView: View {
    @Environment(\.requestReview) private var requestReview

    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @AppStorage("userName") private var userName: String = ""
    @AppStorage(SettingsKeys.intention) private var intention: String = ""

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

                    ScrollView(showsIndicators: false) {
                        AppPanel {
                            VStack(spacing: isCompact ? 14 : 20) {
                                heroCard(isCompact: isCompact)
                                dailyFocusCard
                                highlightsCard
                                motivationQuote
                                toolsRow
                                adBannerTile
                                footerQuote
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            stats = JapaStatsManager.shared.load()
            motivation = motivationQuotes.randomElement() ?? ""
            requestReviewIfAppropriate()
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
                HighlightStatCard(label: "Meditation Mins", value: "\(todayMeditationMinutes())")
            }
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var dailyFocusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Daily Focus")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(focusTitle())
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    Text(focusMessage())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "sun.max.fill")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 10) {
                FocusMetricTile(label: "Rounds", value: "\(todayRounds())")
                FocusMetricTile(label: "Minutes", value: "\(todayMeditationMinutes())")
            }

            HStack(spacing: 12) {
                NavigationLink(destination: CounterView()) {
                    DailyFocusActionButton(
                        icon: "circle.dotted",
                        title: "Start Japa",
                        subtitle: "Chant now"
                    )
                }

                NavigationLink(destination: MeditationView()) {
                    DailyFocusActionButton(
                        icon: "figure.mind.and.body",
                        title: "Start Meditation",
                        subtitle: "Breathe now"
                    )
                }
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

    func todayMeditationMinutes() -> Int {
        let today = formattedDate(Date())
        return stats.dailyMeditationMinutes[today, default: 0]
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

    func requestReviewIfAppropriate() {
        guard RatingPromptManager.shared.shouldRequestReview(for: .appOpened, stats: stats) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            requestReview()
        }
    }

    func focusTitle() -> String {
        let trimmed = intention.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Settle into today's practice" : "\(trimmed) for today"
    }

    func focusMessage() -> String {
        let rounds = todayRounds()
        let minutes = todayMeditationMinutes()

        if rounds > 0 && minutes > 0 {
            return "You have touched both chanting and meditation today. Keep the rhythm gentle."
        }

        if rounds > 0 {
            return "Your Japa is underway. A short meditation can complete today's balance."
        }

        if minutes > 0 {
            return "You made space to breathe. One Japa round can carry that stillness forward."
        }

        if stats.currentStreak > 0 {
            return "Continue your \(stats.currentStreak)-day streak with one round or a quiet meditation."
        }

        return "Begin with one round or a few quiet minutes. Small practice still counts."
    }
}

struct DailyFocusActionButton: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.headline)
                    .opacity(0.95)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .opacity(0.88)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
        .foregroundColor(.white)
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.26))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.38), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 10, y: 5)
    }
}

struct FocusMetricTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.88))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.16))
        .cornerRadius(14)
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
