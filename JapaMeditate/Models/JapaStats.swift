//
//  JapaStats.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import Foundation

struct JapaStats: Codable {
    // Japa stats
    var lifetimeRounds: Int = 0
    var lifetimeBeads: Int = 0
    var bestStreak: Int = 0
    var currentStreak: Int = 0
    var lastActiveDate: Date = Date.distantPast
    var dailyRounds: [String: Int] = [:]   // dateString -> rounds

    // Meditation stats
    var lifetimeMeditationSessions: Int = 0          // how many sessions completed
    var lifetimeMeditationMinutes: Int = 0           // total minutes
    var lastMeditationDate: Date? = nil              // when last meditated
    var dailyMeditationSessions: [String: Int] = [:] // dateString -> sessions
    var dailyMeditationMinutes: [String: Int] = [:]  // dateString -> minutes

    enum CodingKeys: String, CodingKey {
        case lifetimeRounds
        case lifetimeBeads
        case bestStreak
        case currentStreak
        case lastActiveDate
        case dailyRounds
        case lifetimeMeditationSessions
        case lifetimeMeditationMinutes
        case lastMeditationDate
        case dailyMeditationSessions
        case dailyMeditationMinutes
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        lifetimeRounds = try container.decodeIfPresent(Int.self, forKey: .lifetimeRounds) ?? 0
        lifetimeBeads = try container.decodeIfPresent(Int.self, forKey: .lifetimeBeads) ?? 0
        bestStreak = try container.decodeIfPresent(Int.self, forKey: .bestStreak) ?? 0
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        lastActiveDate = try container.decodeIfPresent(Date.self, forKey: .lastActiveDate) ?? Date.distantPast
        dailyRounds = try container.decodeIfPresent([String: Int].self, forKey: .dailyRounds) ?? [:]

        lifetimeMeditationSessions = try container.decodeIfPresent(Int.self, forKey: .lifetimeMeditationSessions) ?? 0
        lifetimeMeditationMinutes = try container.decodeIfPresent(Int.self, forKey: .lifetimeMeditationMinutes) ?? 0
        lastMeditationDate = try container.decodeIfPresent(Date.self, forKey: .lastMeditationDate)
        dailyMeditationSessions = try container.decodeIfPresent([String: Int].self, forKey: .dailyMeditationSessions) ?? [:]
        dailyMeditationMinutes = try container.decodeIfPresent([String: Int].self, forKey: .dailyMeditationMinutes) ?? [:]
    }
}
