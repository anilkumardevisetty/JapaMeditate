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

    // 3-column grid if you ever want 3 tiles
    private let threeColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Header tile (matches Home hero style)
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

                    // MARK: - Today card (theme gradient + 2 equal tiles)
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
                            JapaStatTile(label: "Today’s Rounds",
                                         value: "\(todayRounds())")

                            JapaStatTile(label: "Current Streak",
                                         value: "\(stats.currentStreak)d")
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedTheme.background)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                    
                    // MARK: - Ad banner (already themed on Home)
                    StyledBanner() // 👈 looks like part of the UI

                    // MARK: - Lifetime card (theme gradient + 3 equal tiles)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lifetime")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(columns: threeColumns, spacing: 10) {
                            JapaStatTile(label: "Best Streak",
                                         value: "\(stats.bestStreak)d")

                            JapaStatTile(label: "Lifetime Rounds",
                                         value: "\(stats.lifetimeRounds)")

                            JapaStatTile(label: "Lifetime Beads",
                                         value: "\(stats.lifetimeBeads)")
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
        .navigationTitle("Japa Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            stats = JapaStatsManager.shared.load()
        }
    }

    // MARK: - Helpers

    private func todayKey() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func todayRounds() -> Int {
        stats.dailyRounds[todayKey(), default: 0]
    }

    private func todayDisplayDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
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
        .frame(maxWidth: .infinity, minHeight: 72)   // same width + height
        .background(Color.white.opacity(0.18))       // same as HighlightStatCard
        .cornerRadius(16)
    }
}
