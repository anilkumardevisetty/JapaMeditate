//
//  MeditationHapticsManager.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import CoreHaptics
import UIKit

class MeditationHapticsManager {
    static let shared = MeditationHapticsManager()

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    init() {
        prepareHaptics()
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine failure: \(error.localizedDescription)")
        }
    }

    /// Start continuous vibration (0.0 – 1.0 intensity)
    func startContinuous(intensity: Float = 0.4) {
        guard let engine else { return }

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0,
            duration: 3.0    // engine allows continuous/long duration
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            continuousPlayer = player
            try player.start(atTime: 0)
        } catch {
            print("Continuous haptic error: \(error.localizedDescription)")
        }
    }

    /// Stop continuous vibration
    func stopContinuous() {
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop continuous haptics:", error.localizedDescription)
        }
    }
}


