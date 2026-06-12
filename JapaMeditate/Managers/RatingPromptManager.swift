//
//  RatingPromptManager.swift
//  JapaMeditate
//
//  Created by Anilkumar Devisetty on 6/11/26.
//
import Foundation

final class RatingPromptManager {
    static let shared = RatingPromptManager()

    private let promptedMilestonesKey = "ratingPrompt.promptedMilestones"
    private let lastPromptDateKey = "ratingPrompt.lastPromptDate"
    private let firstSeenDateKey = "ratingPrompt.firstSeenDate"

    private let japaMilestones: Set<Int> = [1, 3, 10, 25, 50]
    private let meditationMilestones: Set<Int> = [2, 5, 10, 25]
    private let appOpenDayMilestones: Set<Int> = [2, 5, 10, 25, 50]
    private let minimumDaysBetweenPrompts = 7

    private init() {}

    func shouldRequestReview(for event: PracticeEvent, stats: JapaStats) -> Bool {
        guard let milestone = milestoneKey(for: event, stats: stats) else { return false }
        guard !promptedMilestones.contains(milestone) else { return false }
        guard hasWaitedLongEnoughSinceLastPrompt() else { return false }

        markPrompted(milestone)
        return true
    }

    private var promptedMilestones: Set<String> {
        let values = UserDefaults.standard.stringArray(forKey: promptedMilestonesKey) ?? []
        return Set(values)
    }

    private func milestoneKey(for event: PracticeEvent, stats: JapaStats) -> String? {
        switch event {
        case .appOpened:
            let daysSinceFirstSeen = daysSinceFirstSeen()
            guard appOpenDayMilestones.contains(daysSinceFirstSeen) else { return nil }
            return "app-open-day-\(daysSinceFirstSeen)"

        case .japaRoundCompleted:
            guard japaMilestones.contains(stats.lifetimeRounds) else { return nil }
            return "japa-\(stats.lifetimeRounds)"

        case .meditationCompleted:
            guard meditationMilestones.contains(stats.lifetimeMeditationSessions) else { return nil }
            return "meditation-\(stats.lifetimeMeditationSessions)"
        }
    }

    private func daysSinceFirstSeen() -> Int {
        let defaults = UserDefaults.standard

        if let firstSeenDate = defaults.object(forKey: firstSeenDateKey) as? Date {
            let start = Calendar.current.startOfDay(for: firstSeenDate)
            let today = Calendar.current.startOfDay(for: Date())
            return Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        }

        defaults.set(Date(), forKey: firstSeenDateKey)
        return 0
    }

    private func hasWaitedLongEnoughSinceLastPrompt() -> Bool {
        guard let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date else {
            return true
        }

        let nextAllowedDate = Calendar.current.date(
            byAdding: .day,
            value: minimumDaysBetweenPrompts,
            to: lastPromptDate
        ) ?? lastPromptDate

        return Date() >= nextAllowedDate
    }

    private func markPrompted(_ milestone: String) {
        var milestones = promptedMilestones
        milestones.insert(milestone)
        UserDefaults.standard.set(Array(milestones), forKey: promptedMilestonesKey)
        UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)
    }

    #if DEBUG
    func resetForTesting() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: promptedMilestonesKey)
        defaults.removeObject(forKey: lastPromptDateKey)
        defaults.removeObject(forKey: firstSeenDateKey)
    }
    #endif
}

enum PracticeEvent {
    case appOpened
    case japaRoundCompleted
    case meditationCompleted
}
