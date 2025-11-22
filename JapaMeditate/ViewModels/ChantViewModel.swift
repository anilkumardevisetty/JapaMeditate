//
//  ChantViewModel.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI
import CoreHaptics
import Combine

import SwiftUI

class ChantViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var total: Int = 108
    @Published var sessions: [ChantSession] = []
    @Published var justCompleted: Bool = false

    var progress: Double {
        Double(count) / Double(total)
    }

    func increment() {
        guard count < total else { return }
        count += 1

        // ✅ safer read with default = true
        let hapticsEnabled = (UserDefaults.standard.object(forKey: SettingsKeys.hapticsEnabled) as? Bool) ?? true
        if hapticsEnabled {
            HapticsManager.shared.trigger(for: count)
        }

        if count == total {
            completeSession()
        }
    }

    private func completeSession() {
        let session = ChantSession(timestamp: Date(), count: count)
        sessions.append(session)

        if UserDefaults.standard.bool(forKey: SettingsKeys.hapticsEnabled) {
            HapticsManager.shared.finalTriplePulse()
        }
        justCompleted = true

        // auto reset after glow
        if UserDefaults.standard.bool(forKey: SettingsKeys.autoReset) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.reset()
                self.justCompleted = false
            }
        }

    }

    func reset() {
        count = 0
    }
    
    func completeOneRound() {
        var stats = JapaStatsManager.shared.load()
        
        let today = dateString(Date())
        let yesterday = dateString(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        // Increment today's rounds
        stats.dailyRounds[today, default: 0] += 1
        stats.lifetimeRounds += 1
        stats.lifetimeBeads += 108
        
        // Update streak
        if stats.lastActiveDate == Date.distantPast {
            // first time ever
            stats.currentStreak = 1
        } else {
            let last = dateString(stats.lastActiveDate)
            
            if last == yesterday {
                stats.currentStreak += 1
            } else if last != today {
                stats.currentStreak = 1
            }
        }
        
        stats.bestStreak = max(stats.bestStreak, stats.currentStreak)
        stats.lastActiveDate = Date()
        
        JapaStatsManager.shared.save(stats)
    }

    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

}
