import SwiftUI
import UserNotifications
import GoogleMobileAds

@main
struct JapaMeditateApp: App {

    @AppStorage(SettingsKeys.didCompleteOnboarding) private var didCompleteOnboarding: Bool = false

    init() {
        Self.markExistingUsersOnboarded()
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if didCompleteOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
        }
    }

    private static func markExistingUsersOnboarded() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: SettingsKeys.didCompleteOnboarding) == nil else { return }
        guard defaults.object(forKey: SettingsKeys.didRequestNotificationPermission) != nil else { return }
        defaults.set(true, forKey: SettingsKeys.didCompleteOnboarding)
    }
}
