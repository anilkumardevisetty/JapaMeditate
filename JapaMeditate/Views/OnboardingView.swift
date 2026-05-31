import SwiftUI

struct OnboardingView: View {
    @AppStorage(SettingsKeys.didCompleteOnboarding) private var didCompleteOnboarding: Bool = false
    @AppStorage(SettingsKeys.didRequestNotificationPermission) private var didRequestNotificationPermission: Bool = false
    @AppStorage(SettingsKeys.userName) private var savedUserName: String = ""
    @AppStorage(SettingsKeys.intention) private var savedIntention: String = ""
    @AppStorage(SettingsKeys.mantra) private var selectedMantra: String = Mantra.omNamahShivaya.rawValue
    @AppStorage(SettingsKeys.remindersEnabled) private var remindersEnabled: Bool = true
    @AppStorage(SettingsKeys.reminderTime) private var reminderTime: Double = 18 * 3600
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    @State private var pageIndex: Int = 0
    @State private var name: String = ""
    @State private var intention: String = "Peace"
    @State private var mantra: Mantra = .omNamahShivaya
    @State private var enableReminder: Bool = true
    @State private var reminderDate: Date = Self.dateFromSecondsSinceMidnight(18 * 3600)

    private let intentions = ["Peace", "Focus", "Devotion", "Healing"]
    private let pageCount = 3

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            AppPanel {
                VStack(spacing: 18) {
                    progressDots

                    TabView(selection: $pageIndex) {
                        intentionPage.tag(0)
                        mantraPage.tag(1)
                        reminderPage.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 500)

                    controls
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            name = savedUserName
            intention = savedIntention.isEmpty ? "Peace" : savedIntention
            mantra = Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
            enableReminder = remindersEnabled
            reminderDate = Self.dateFromSecondsSinceMidnight(reminderTime)
        }
    }
}

private extension OnboardingView {

    var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == pageIndex ? Color.black : Color.black.opacity(0.18))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 4)
    }

    var intentionPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            header(
                icon: "sparkles",
                title: "Begin with intention",
                subtitle: "Personalize JapaMeditate around the feeling you want to cultivate."
            )

            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)

            VStack(alignment: .leading, spacing: 10) {
                Text("Choose your intention")
                    .font(.headline)
                    .foregroundColor(.white)

                LazyVGrid(columns: twoColumns, spacing: 10) {
                    ForEach(intentions, id: \.self) { option in
                        selectionChip(
                            title: option,
                            icon: iconForIntention(option),
                            isSelected: intention == option
                        ) {
                            intention = option
                        }
                    }
                }
            }

            Spacer()
        }
        .onboardingCard(background: selectedTheme.background)
    }

    var mantraPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            header(
                icon: "circle.dotted",
                title: "Choose your mantra",
                subtitle: "Start with a traditional mantra. You can add a custom mantra later in Settings."
            )

            VStack(spacing: 10) {
                ForEach(Mantra.allCases.filter { $0 != .custom }) { option in
                    Button {
                        mantra = option
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: mantra == option ? "checkmark.circle.fill" : "circle")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .font(.headline)
                                Text(option.transliteration)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white.opacity(mantra == option ? 0.28 : 0.14))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()
        }
        .onboardingCard(background: selectedTheme.background)
    }

    var reminderPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            header(
                icon: "bell.fill",
                title: "Make it a daily habit",
                subtitle: "A gentle reminder can help your practice become part of the day."
            )

            Toggle("Daily reminder", isOn: $enableReminder)
                .font(.headline)
                .foregroundColor(.white)
                .tint(.white)

            if enableReminder {
                DatePicker(
                    "Reminder time",
                    selection: $reminderDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .font(.headline)
                .foregroundColor(.white)
                .tint(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Your setup")
                    .font(.headline)
                    .foregroundColor(.white)

                setupRow(icon: "person.fill", text: name.trimmingCharacters(in: .whitespaces).isEmpty ? "Guest" : name)
                setupRow(icon: "heart.fill", text: intention)
                setupRow(icon: "circle.dotted", text: mantra.title)
            }
            .padding(14)
            .background(Color.white.opacity(0.14))
            .cornerRadius(18)

            Spacer()
        }
        .onboardingCard(background: selectedTheme.background)
    }

    var controls: some View {
        HStack(spacing: 12) {
            if pageIndex > 0 {
                Button("Back") {
                    withAnimation {
                        pageIndex -= 1
                    }
                }
                .buttonStyle(OnboardingSecondaryButtonStyle())
            }

            Button(pageIndex == pageCount - 1 ? "Start Practice" : "Continue") {
                if pageIndex == pageCount - 1 {
                    finishOnboarding()
                } else {
                    withAnimation {
                        pageIndex += 1
                    }
                }
            }
            .buttonStyle(OnboardingPrimaryButtonStyle(background: selectedTheme.background))
        }
    }

    var twoColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    }

    func header(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())

            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func selectionChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity, minHeight: 82)
            .background(Color.white.opacity(isSelected ? 0.28 : 0.14))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(isSelected ? 0.9 : 0.0), lineWidth: 1)
            )
            .cornerRadius(16)
            .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    func setupRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(text)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Spacer()
        }
        .foregroundColor(.white)
    }

    func iconForIntention(_ value: String) -> String {
        switch value {
        case "Focus": return "scope"
        case "Devotion": return "hands.sparkles.fill"
        case "Healing": return "leaf.fill"
        default: return "moon.stars.fill"
        }
    }

    func finishOnboarding() {
        savedUserName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        savedIntention = intention
        selectedMantra = mantra.rawValue
        remindersEnabled = enableReminder
        reminderTime = Self.secondsSinceMidnight(from: reminderDate)

        if enableReminder {
            didRequestNotificationPermission = true
            NotificationManager.shared.requestPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                        NotificationManager.shared.scheduleDailyReminder(
                            hour: comps.hour ?? 18,
                            minute: comps.minute ?? 0
                        )
                    } else {
                        remindersEnabled = false
                    }
                    didCompleteOnboarding = true
                }
            }
        } else {
            NotificationManager.shared.cancelDailyReminder()
            didCompleteOnboarding = true
        }
    }

    static func dateFromSecondsSinceMidnight(_ seconds: Double) -> Date {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: Date())
        return startOfDay.addingTimeInterval(seconds)
    }

    static func secondsSinceMidnight(from date: Date) -> Double {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return Double((comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60)
    }
}

private struct OnboardingCardModifier: ViewModifier {
    let background: LinearGradient

    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(background)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}

private extension View {
    func onboardingCard(background: LinearGradient) -> some View {
        modifier(OnboardingCardModifier(background: background))
    }
}

private struct OnboardingPrimaryButtonStyle: ButtonStyle {
    let background: LinearGradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(background)
            .cornerRadius(18)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.black)
            .frame(width: 96, height: 52)
            .background(Color.black.opacity(0.08))
            .cornerRadius(18)
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
