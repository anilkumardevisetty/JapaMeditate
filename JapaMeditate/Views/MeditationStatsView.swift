//
//  MeditationStatsView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct MeditationStatsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @State private var stats: JapaStats = JapaStatsManager.shared.load()

    var body: some View {
        ZStack {
            selectedTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Meditation Stats")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Text("Track your breathing practice over time.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)

                    // Today card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))

                        HStack {
                            StatBox(
                                title: "Sessions",
                                value: "\(todaySessions)"
                            )

                            StatBox(
                                title: "Minutes",
                                value: "\(todayMinutes)"
                            )

                            StatBox(
                                title: "Total Sessions",
                                value: "\(stats.lifetimeMeditationSessions)"
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    StyledBanner() // 👈 looks like part of the UI
                            .padding(.bottom, 10)

                    // Lifetime section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lifetime")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Total Minutes:")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\(stats.lifetimeMeditationMinutes)")
                                    .foregroundColor(.white)
                                    .bold()
                            }

                            HStack {
                                Text("Total Sessions:")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\(stats.lifetimeMeditationSessions)")
                                    .foregroundColor(.white)
                                    .bold()
                            }

                            HStack {
                                Text("Last Session:")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(lastMeditationString)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
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

    private var todayMinutes: Int {
        // Assumes each session length was persisted as selectedSessionLength (in minutes).
        // For now we approximate: todaySessions * averageMinutesPerSession
        // If you want exact per-session minutes, you can store more detail later.
        // Using 5-minute default average just as a safe placeholder.
        return stats.dailyMeditationSessions[todayKey, default: 0] * 5
    }

    private var lastMeditationString: String {
        guard let date = stats.lastMeditationDate else {
            return "—"
        }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

struct MeditationStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MeditationStatsView()
        }
    }
}

