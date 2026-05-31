//
//  StatsView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//

import SwiftUI

struct StatsView: View {
    @State private var stats = JapaStatsManager.shared.load()
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    // 2-column grid for Japa tiles
    private let twoColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 2
    )

    // 3-column grid
    private let threeColumns: [GridItem] = Array(
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
                        practiceCalendarCard
                        insightsCard
                        milestonesCard
                        StyledBanner()
                        lifetimeCard
                    }
                }
                .padding(.top, 8)       // keeps rounded top edge visible
                .padding(.bottom, 8)    // keeps rounded bottom edge visible
            }
        }
        .navigationTitle("Japa Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            stats = JapaStatsManager.shared.load()
        }
    }
}

// MARK: - Sections
private extension StatsView {

    var headerTile: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Japa Stats")
                .font(.title.bold())
                .foregroundColor(.white)

            Text("See your chanting progress at a glance.")
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

                Text(todayDisplayDate())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }

            LazyVGrid(columns: twoColumns, spacing: 10) {
                JapaStatTile(label: "Today’s Rounds", value: "\(todayRounds())")
                JapaStatTile(label: "Current Streak", value: "\(stats.currentStreak)d")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    var lifetimeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lifetime")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: threeColumns, spacing: 10) {
                JapaStatTile(label: "Best Streak", value: "\(stats.bestStreak)d")
                JapaStatTile(label: "Lifetime Rounds", value: "\(stats.lifetimeRounds)")
                JapaStatTile(label: "Lifetime Beads", value: "\(stats.lifetimeBeads)")
            }
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
            valuesByDate: stats.dailyRounds,
            metricName: "round",
            metricPluralName: "rounds",
            theme: selectedTheme
        )
    }

    var insightsCard: some View {
        PracticeInsightsCard(
            valuesByDate: stats.dailyRounds,
            metricName: "round",
            metricPluralName: "rounds",
            bestDayLabel: "Best day",
            averageLabel: "Daily average",
            consistencyLabel: "Consistency",
            emptyMessage: "Complete a round to unlock your first Japa insight.",
            theme: selectedTheme
        )
    }

    var milestonesCard: some View {
        MilestoneBadgesCard(
            title: "Milestones",
            milestones: japaMilestones,
            theme: selectedTheme
        )
    }
}

// MARK: - Helpers
private extension StatsView {

    func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    func todayRounds() -> Int {
        stats.dailyRounds[todayKey(), default: 0]
    }

    func todayDisplayDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }

    var japaMilestones: [PracticeMilestone] {
        [
            PracticeMilestone(
                id: "first-round",
                title: "First Round",
                subtitle: stats.lifetimeRounds >= 1 ? "Your practice has begun" : "Complete 1 round",
                systemImage: "circle.circle.fill",
                isUnlocked: stats.lifetimeRounds >= 1
            ),
            PracticeMilestone(
                id: "seven-active-days",
                title: "7 Active Days",
                subtitle: "\(activeJapaDays) days recorded",
                systemImage: "calendar.badge.checkmark",
                isUnlocked: activeJapaDays >= 7
            ),
            PracticeMilestone(
                id: "one-oh-eight-rounds",
                title: "108 Rounds",
                subtitle: "\(stats.lifetimeRounds) lifetime rounds",
                systemImage: "sparkles",
                isUnlocked: stats.lifetimeRounds >= 108
            ),
            PracticeMilestone(
                id: "week-streak",
                title: "7 Day Streak",
                subtitle: "Best streak: \(stats.bestStreak)d",
                systemImage: "flame.fill",
                isUnlocked: stats.bestStreak >= 7
            )
        ]
    }

    var activeJapaDays: Int {
        stats.dailyRounds.values.filter { $0 > 0 }.count
    }
}

// MARK: - Reusable Japa stat tile (matches HighlightStatCard style)
struct JapaStatTile: View {
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
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(Color.white.opacity(0.18))
        .cornerRadius(16)
    }
}
