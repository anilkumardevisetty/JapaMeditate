//
//  SettingsView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//

import SwiftUI
#if DEBUG
import StoreKit
#endif

struct SettingsView: View {
    #if DEBUG
    @Environment(\.requestReview) private var requestReview
    #endif

    @AppStorage(SettingsKeys.didCompleteOnboarding) private var didCompleteOnboarding: Bool = true
    @AppStorage(SettingsKeys.mantra) private var selectedMantra: String = Mantra.omNamahShivaya.rawValue
    @AppStorage(SettingsKeys.target) private var targetCount: Int = 108
    @AppStorage(SettingsKeys.hapticsEnabled) private var hapticsEnabled: Bool = true
    @AppStorage(SettingsKeys.autoReset) private var autoReset: Bool = true
    @AppStorage(SettingsKeys.wordAnimationEnabled) private var wordAnimationEnabled: Bool = false
    @AppStorage("customMantraText") private var customMantraText: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @AppStorage("userName") private var userName: String = ""

    // Defaults: ON + 6:00 PM
    @AppStorage(SettingsKeys.remindersEnabled) private var remindersEnabled: Bool = true
    // Store as seconds since midnight (local time)
    @AppStorage(SettingsKeys.reminderTime) private var reminderTime: Double = 18 * 3600

    var body: some View {
        Form {
            var currentMantra: Mantra {
                Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
            }

            // MARK: Profile
            Section(header: Text("Profile")) {
                TextField("Your name", text: $userName)
            }

            #if DEBUG
            Section(header: Text("Testing")) {
                Button("Show Onboarding Again") {
                    didCompleteOnboarding = false
                }

                Button("Reset Rating Prompt Testing") {
                    RatingPromptManager.shared.resetForTesting()
                }

                Button("Force Review Prompt") {
                    requestReview()
                }
            }
            #endif

            // MARK: Mantra
            Section(header: Text("Mantra")) {
                Picker("Select Mantra", selection: $selectedMantra) {
                    ForEach(Mantra.allCases) { mantra in
                        Text(mantra.title).tag(mantra.rawValue)
                    }
                }

                if selectedMantra == Mantra.custom.rawValue {
                    TextField("Enter custom mantra", text: $customMantraText)
                        .textFieldStyle(.roundedBorder)
                }

                NavigationLink("Preview Mantra") {
                    MantraPreviewView(
                        mantra: currentMantra,
                        customText: customMantraText
                    )
                }
            }

            // MARK: Behavior
            Section(header: Text("Behavior")) {
                Toggle("Haptics Enabled", isOn: $hapticsEnabled)
                Toggle("Auto Reset After Completion", isOn: $autoReset)
                Toggle("Word Animation", isOn: $wordAnimationEnabled)
            }

            // MARK: Themes
            Section {
                NavigationLink(destination: ThemeView()) {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                        Text("Themes")
                        Spacer()
                        Text(selectedTheme.title)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // MARK: Daily Reminder
            Section(header: Text("Daily Reminder")) {

                Toggle("Enable Daily Reminder", isOn: $remindersEnabled)
                    .onChange(of: remindersEnabled) { enabled in
                        if enabled {
                            NotificationManager.shared.requestPermission { granted in
                                guard granted else {
                                    // If denied, flip toggle back off (avoids confusion)
                                    DispatchQueue.main.async {
                                        remindersEnabled = false
                                    }
                                    return
                                }

                                let date = dateFromSecondsSinceMidnight(reminderTime)
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)

                                NotificationManager.shared.scheduleDailyReminder(
                                    hour: comps.hour ?? 18,
                                    minute: comps.minute ?? 0
                                )
                            }
                        } else {
                            NotificationManager.shared.cancelDailyReminder()
                        }
                    }

                if remindersEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { dateFromSecondsSinceMidnight(reminderTime) },
                            set: { newValue in
                                reminderTime = secondsSinceMidnight(from: newValue)
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)

                                NotificationManager.shared.scheduleDailyReminder(
                                    hour: comps.hour ?? 18,
                                    minute: comps.minute ?? 0
                                )
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                } else {
                    Text("If reminders don’t work, enable notifications in iPhone Settings → Notifications → JapaMeditate.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .navigationTitle("Settings")
    }

    // MARK: - Time Helpers (seconds since midnight <-> Date)
    private func dateFromSecondsSinceMidnight(_ seconds: Double) -> Date {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())
        return startOfDay.addingTimeInterval(seconds)
    }

    private func secondsSinceMidnight(from date: Date) -> Double {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: date)
        return Double((comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60)
    }
}
