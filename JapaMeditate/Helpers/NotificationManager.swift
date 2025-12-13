//
//  NotificationManager.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//

import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let reminderId = "daily_japa_reminder"

    /// Requests permission if needed. Calls completion with the final authorization result.
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion?(true)

            case .denied:
                completion?(false)

            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error = error {
                        print("Notification permission error:", error)
                    }
                    completion?(granted)
                }

            @unknown default:
                completion?(false)
            }
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        // Always keep only one pending reminder request
        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "Time for Your Japa Practice"
        content.body = "Let’s continue your spiritual journey today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: reminderId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder:", error)
            }
        }
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId])
    }
}
