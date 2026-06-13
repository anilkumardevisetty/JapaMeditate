//
//  AnalyticsManager.swift
//  JapaMeditate
//
//  Created by Anilkumar Devisetty on 6/12/26.
//
import Foundation
import FirebaseAnalytics
import FirebaseCore

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private var isConfigured = false

    private init() {}

    func configureIfAvailable() {
        guard FirebaseApp.app() == nil else {
            isConfigured = true
            return
        }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return
        }

        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        isConfigured = true
    }

    func log(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        guard isConfigured else { return }
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}

enum AnalyticsEvent: String {
    case onboardingCompleted = "onboarding_completed"
    case homeViewed = "home_viewed"
    case japaStarted = "japa_started"
    case japaRoundCompleted = "japa_round_completed"
    case meditationStarted = "meditation_started"
    case meditationCompleted = "meditation_completed"
    case japaStatsViewed = "japa_stats_viewed"
    case meditationStatsViewed = "meditation_stats_viewed"
}
