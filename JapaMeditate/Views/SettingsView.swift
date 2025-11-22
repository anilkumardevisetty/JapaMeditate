//
//  SettingsView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.mantra) private var selectedMantra: String = Mantra.omNamahShivaya.rawValue
    @AppStorage(SettingsKeys.target) private var targetCount: Int = 108
    @AppStorage(SettingsKeys.hapticsEnabled) private var hapticsEnabled: Bool = true
    @AppStorage(SettingsKeys.autoReset) private var autoReset: Bool = true
    @AppStorage(SettingsKeys.wordAnimationEnabled) private var wordAnimationEnabled: Bool = false
    @AppStorage("customMantraText") private var customMantraText: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    
    @AppStorage(SettingsKeys.remindersEnabled) private var remindersEnabled: Bool = false
    @AppStorage(SettingsKeys.reminderTime) private var reminderTime: Double = 7 * 3600 // 7:00 AM

    var body: some View {
        Form {
            var currentMantra: Mantra {
                Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
            }

            // MARK: Mantra Section
            Section(header: Text("Mantra")) {

                Picker("Select Mantra", selection: $selectedMantra) {
                    ForEach(Mantra.allCases) { mantra in
                        Text(mantra.title).tag(mantra.rawValue)
                    }
                }

                // Custom mantra input
                if selectedMantra == Mantra.custom.rawValue {
                    TextField("Enter custom mantra", text: $customMantraText)
                        .textFieldStyle(.roundedBorder)
                }

                // Preview button
                NavigationLink("Preview Mantra") {
                    MantraPreviewView(
                        mantra: currentMantra,
                        customText: customMantraText
                    )
                }
            }
            
            // MARK: Target Count Section
//            Section(header: Text("Target Count")) {
//                Picker("Repeats per round", selection: $targetCount) {
//                    Text("108").tag(108)
//                    Text("54").tag(54)
//                    Text("27").tag(27)
//                    Text("1008").tag(1008)
//                }
//                .pickerStyle(.segmented)
//            }

            // MARK: Vibration & Auto Reset
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
            
            //MARK: Notifications
            Section(header: Text("Daily Reminder")) {

                Toggle("Enable Daily Reminder", isOn: $remindersEnabled)
                    .onChange(of: remindersEnabled) { enabled in
                        if enabled {
                            NotificationManager.shared.requestPermission()

                            let date = Date(timeIntervalSince1970: reminderTime)
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                            
                            if let hour = comps.hour, let minute = comps.minute {
                                NotificationManager.shared.scheduleDailyReminder(hour: hour, minute: minute)
                            }
                        } else {
                            NotificationManager.shared.cancelDailyReminder()
                        }
                    }

                if remindersEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { Date(timeIntervalSince1970: reminderTime) },
                            set: { newValue in
                                reminderTime = newValue.timeIntervalSince1970
                                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                NotificationManager.shared.scheduleDailyReminder(
                                    hour: comps.hour ?? 7,
                                    minute: comps.minute ?? 0
                                )
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }

        }
        .navigationTitle("Settings")
    }
}
