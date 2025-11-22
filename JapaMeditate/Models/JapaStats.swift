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
}
