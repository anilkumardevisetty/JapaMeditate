import SwiftUI
import UserNotifications
import GoogleMobileAds

@main
struct JapaMeditateApp: App {

    @AppStorage("didRequestNotificationPermission") private var didRequestNotificationPermission: Bool = false

    // Defaults: ON + 6 PM
    @AppStorage(SettingsKeys.remindersEnabled) private var remindersEnabled: Bool = true
    @AppStorage(SettingsKeys.reminderTime) private var reminderTime: Double = 18 * 3600

    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .onAppear {
                handleFirstLaunchNotifications()
            }
        }
    }

    private func handleFirstLaunchNotifications() {
        guard !didRequestNotificationPermission else { return }
        didRequestNotificationPermission = true

        // Set defaults on first run
        remindersEnabled = true
        reminderTime = 18 * 3600

        // Ask permission, then schedule only if granted AND remindersEnabled
        NotificationManager.shared.requestPermission { granted in
            guard granted else { return }
            guard remindersEnabled else { return }
            NotificationManager.shared.scheduleDailyReminder(hour: 18, minute: 0)
        }
    }
}
