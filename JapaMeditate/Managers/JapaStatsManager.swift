//
//  JapaStatsManager.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import Foundation

class JapaStatsManager {
    static let shared = JapaStatsManager()
    
    private let key = "japaStats"
    
    func load() -> JapaStats {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(JapaStats.self, from: data) {
            return decoded
        }
        return JapaStats()
    }
    
    func save(_ stats: JapaStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

