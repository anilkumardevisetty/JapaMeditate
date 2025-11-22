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

    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your Japa Progress")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top)
                
                statCard(title: "Today's Rounds",
                         value: stats.dailyRounds[today(), default: 0])
                
                statCard(title: "Current Streak",
                         value: stats.currentStreak)
                
//                StyledBanner() // 👈 looks like part of the UI
//                        .padding(.bottom, 10)
                
                statCard(title: "Best Streak",
                         value: stats.bestStreak)
                
                statCard(title: "Lifetime Rounds",
                         value: stats.lifetimeRounds)
                
                statCard(title: "Lifetime Beads",
                         value: stats.lifetimeBeads)
                
                Spacer()
            }
            .padding()
        }
        .background(
            selectedTheme.background.ignoresSafeArea()
        )
        .onAppear {
            stats = JapaStatsManager.shared.load()
        }
    }
    
    func statCard(title: String, value: Int) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            Text("\(value)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
    
    func today() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}

