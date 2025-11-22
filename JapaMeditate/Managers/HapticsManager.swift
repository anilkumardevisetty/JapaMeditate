//
//  HapticsManager.swift.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import UIKit
import CoreHaptics

class HapticsManager {
    static let shared = HapticsManager()

    private let soft = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)

    // MARK: - Main entry used by CounterView
    func trigger(for count: Int) {
        // Milestones → triple pulse
        if [27, 54, 80].contains(count) {
            milestoneTriplePulse()
            return
        }

        // Final (108) → slightly stronger triple pulse
        if count == 108 {
            finalTriplePulse()
            return
        }

        // Normal tap
        soft.impactOccurred()
    }

    // MARK: - Triple-Pulse (Milestones)
    private func milestoneTriplePulse() {
        medium.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.medium.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            self.medium.impactOccurred()
        }
    }

    // MARK: - Triple-Pulse (Final completion — slightly stronger)
    func finalTriplePulse() {
        heavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.heavy.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            self.heavy.impactOccurred()
        }
    }
}
