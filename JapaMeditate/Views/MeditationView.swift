import SwiftUI
import CoreHaptics

// MARK: - Breathing Patterns

enum BreathingPattern: String, CaseIterable, Identifiable {
    case beginner   // 4-2-4
    case calm       // 5-5 (no hold)
    case deepRelax  // 4-7-8
    case focus      // 4-4-4-4 (box)

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginner:  return "Beginner"
        case .calm:      return "Calm"
        case .deepRelax: return "Relax"
        case .focus:     return "Focus"
        }
    }

    var subtitle: String {
        switch self {
        case .beginner:  return "4–2–4 • Easy & smooth"
        case .calm:      return "5–5 • Coherent breathing"
        case .deepRelax: return "4–7–8 • Deep relaxation"
        case .focus:     return "4–4–4–4 • Box breathing"
        }
    }

    var ratioLabel: String {
        switch self {
        case .beginner:  return "4–2–4"
        case .calm:      return "5–5"
        case .deepRelax: return "4–7–8"
        case .focus:     return "4–4–4–4"
        }
    }

    /// Durations in seconds
    var inhale: Double {
        switch self {
        case .beginner:  return 4
        case .calm:      return 5
        case .deepRelax: return 4
        case .focus:     return 4
        }
    }

    /// First hold (after inhale)
    var hold: Double {
        switch self {
        case .beginner:  return 2
        case .calm:      return 0    // no hold phase
        case .deepRelax: return 7
        case .focus:     return 4
        }
    }

    /// Exhale
    var exhale: Double {
        switch self {
        case .beginner:  return 4
        case .calm:      return 5
        case .deepRelax: return 8
        case .focus:     return 4
        }
    }

    /// Second hold (after exhale) – only used for box breathing
    var postHold: Double {
        switch self {
        case .focus:     return 4
        default:         return 0
        }
    }
}

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    // MARK: Breathing State
    enum BreathPhase: String {
        case inhale  = "Breath In"
        case hold    = "Hold"
        case exhale  = "Breath Out"
        case postHold = "Hold "
        case idle    = ""
    }

    @State private var phase: BreathPhase = .idle
    @State private var circleScale: CGFloat = 1.0
    @State private var isRunning: Bool = false
    @State private var cycleCount: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var meditationCompleted: Bool = false

    // Breathing pattern selection
    @State private var selectedPattern: BreathingPattern = .beginner

    // Session length picker
    @State private var showPicker: Bool = false
    @State private var selectedSessionLength: Int = 2

    // To finish current breath cycle when time hits 0
    @State private var shouldEndAtCycleCompletion: Bool = false

    // Completion popup
    @State private var showCompletionPopup: Bool = false

    // Breath timing (seconds) – driven by pattern
    private var inhaleDuration: Double    { selectedPattern.inhale }
    private var holdDuration: Double      { selectedPattern.hold }
    private var exhaleDuration: Double    { selectedPattern.exhale }
    private var postHoldDuration: Double  { selectedPattern.postHold }

    // Minutes options: 1 → 20 mins
    let sessionOptions = Array(stride(from: 1, through: 20, by: 1))

    var formattedRemainingTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            contentContainer

            if showCompletionPopup {
                completionOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {                               // 👈 add this block
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .sheet(isPresented: $showPicker) {
            sessionLengthSheet
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            stopMeditation()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: meditationCompleted) { newValue in
            if newValue {
                playCompletionHaptics()
                showCompletionPopup = true
            }
        }
    }
    private var backButton: some View {
        Button {
            dismiss()   // uses @Environment(\.dismiss)
        } label: {
            Image(systemName: "chevron.left")
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 3)
                )
        }
    }
    
    private var contentContainer: some View {
        AppPanel {
            VStack(spacing: 16) {
                headerTile
                breathingTile
                controlTile
                patternTile
            }
        }
    }

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(Color.white)  // or Color(.systemBackground)
    }

    private var containerStroke: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .stroke(Color.black.opacity(0.06), lineWidth: 1)
    }


}

// MARK: - Subviews
private extension MeditationView {

    var headerTile: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MEDITATION MODE")
                    .font(.caption2.smallCaps())
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                if isRunning {
                    Text(formattedRemainingTime)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }

            Text("Breathe with calm awareness.")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text("Inhale • Hold • Exhale in a gentle guided rhythm.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }


    var breathingTile: some View {
        ZStack {
            selectedTheme.background
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

            VStack(spacing: 12) {
                GeometryReader { geo in
                    let baseSize = min(geo.size.width, geo.size.height) * 1.0

                    ZStack {
                        Text("ॐ")
                            .font(.system(size: baseSize * 0.6, weight: .bold))
                            .foregroundColor(.white.opacity(0.08))

                        Circle()
                            .fill(Color.white.opacity(0.20))
                            .frame(width: baseSize * 0.75, height: baseSize * 0.75)
                            .scaleEffect(circleScale)
                            .animation(
                                .easeInOut(duration: animationDuration()),
                                value: circleScale
                            )

                        VStack(spacing: 8) {
                            Text(phase.rawValue)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .opacity(phase == .idle ? 0 : 1)

                            if isRunning {
                                Text("Cycles: \(cycleCount)")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))

                                Text("\(selectedPattern.title) • \(selectedPattern.ratioLabel)")
                                    .font(.caption2.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                            } else if !meditationCompleted {
                                Text("Tap Start to begin guided breathing.")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                    .frame(width: baseSize, height: baseSize)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .frame(height: 200)              // smaller tile
                .frame(maxWidth: .infinity)

                if isRunning {
                    Text("Remaining \(formattedRemainingTime)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    Text("Screen will stay on during your session.")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(18)
        }
    }

    var controlTile: some View {
        VStack(spacing: 12) {
            if isRunning {
                Button(action: stopMeditation) {
                    Text("End Session")
                        .modifier(MeditationPrimaryButton())
                }
            } else {
                Button(action: startMeditation) {
                    Text("Start Meditation")
                        .modifier(MeditationPrimaryButton())
                }
            }
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
    }

    var patternTile: some View {
        VStack(alignment: .leading, spacing: 12) {
            BreathingPatternSelector(
                selectedPattern: $selectedPattern,
                isRunning: isRunning
            )

            Divider()
                .background(Color.white.opacity(0.25))

            // Session length…
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session Length")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Choose how long you’d like to meditate.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Button(action: { showPicker = true }) {
                    HStack(spacing: 6) {
                        Text("\(selectedSessionLength) min")
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.18))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .background(selectedTheme.background)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
    }

    var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Session Complete")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text("Beautiful practice. Take a moment to notice how you feel.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                StyledBanner() // your existing banner

                // AdMob placeholder
                // AdBannerView()

                Button(action: {
                    showCompletionPopup = false
                    meditationCompleted = false
                }) {
                    Text("Continue")
                        .modifier(MeditationPrimaryButton())
                }
            }
            .padding(24)
            .background(selectedTheme.background)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            .frame(maxWidth: 360)
        }
    }

    var sessionLengthSheet: some View {
        VStack(spacing: 16) {
            Text("Session Length")
                .font(.headline)
                .padding(.top, 16)

            Picker("Session Length", selection: $selectedSessionLength) {
                ForEach(sessionOptions, id: \.self) { num in
                    Text("\(num) minutes").tag(num)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxHeight: 200)

            Button("Done") {
                showPicker = false
            }
            .font(.headline)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 24)
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Logic
private extension MeditationView {

    func animationDuration() -> Double {
        switch phase {
        case .inhale:   return inhaleDuration
        case .hold:     return holdDuration
        case .exhale:   return exhaleDuration
        case .postHold: return postHoldDuration
        case .idle:     return 0.1
        }
    }

    func startMeditation() {
        cycleCount = 0
        meditationCompleted = false
        showCompletionPopup = false
        remainingSeconds = selectedSessionLength * 60
        shouldEndAtCycleCompletion = false

        isRunning = true

        runBreathingCycle()
        countdownTimer()
    }

    func stopMeditation() {
        isRunning = false
        phase = .idle
        circleScale = 1.0

        MeditationHapticsManager.shared.stopContinuous()
    }

    func countdownTimer() {
        guard isRunning else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard isRunning else { return }

            remainingSeconds -= 1

            if remainingSeconds <= 0 {
                shouldEndAtCycleCompletion = true
                return
            }

            countdownTimer()
        }
    }

    func recordCompletedMeditationSession() {
        var stats = JapaStatsManager.shared.load()

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())

        stats.lifetimeMeditationSessions += 1
        stats.lifetimeMeditationMinutes += selectedSessionLength
        stats.dailyMeditationSessions[today, default: 0] += 1
        stats.lastMeditationDate = Date()

        JapaStatsManager.shared.save(stats)
    }

    func runBreathingCycle() {
        guard isRunning else { return }

        func completeCycle() {
            MeditationHapticsManager.shared.stopContinuous()
            cycleCount += 1

            if shouldEndAtCycleCompletion || remainingSeconds <= 0 {
                meditationCompleted = true
                stopMeditation()
                recordCompletedMeditationSession()
            } else {
                runBreathingCycle()
            }
        }

        func performPostHoldIfNeeded() {
            if postHoldDuration > 0 {
                phase = .postHold
                circleScale = 0.95
                MeditationHapticsManager.shared.stopContinuous()

                DispatchQueue.main.asyncAfter(deadline: .now() + postHoldDuration) {
                    guard isRunning else { return }
                    completeCycle()
                }
            } else {
                completeCycle()
            }
        }

        func startExhale() {
            phase = .exhale
            circleScale = 0.9
            MeditationHapticsManager.shared.startContinuous()

            DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                guard isRunning else { return }
                MeditationHapticsManager.shared.stopContinuous()
                performPostHoldIfNeeded()
            }
        }

        func performHoldIfNeeded() {
            if holdDuration > 0 {
                phase = .hold
                circleScale = 1.4
                MeditationHapticsManager.shared.stopContinuous()

                DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                    guard isRunning else { return }
                    startExhale()
                }
            } else {
                startExhale()
            }
        }

        // INHALE
        phase = .inhale
        circleScale = 1.35
        MeditationHapticsManager.shared.startContinuous()

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard isRunning else { return }
            performHoldIfNeeded()
        }
    }
}

// MARK: - Haptics helper

private func playCompletionHaptics() {
    Task { @MainActor in
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()

        for _ in 0..<10 {
            generator.impactOccurred()
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
    }
}

// MARK: - Button style

private struct MeditationPrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.20))
            .clipShape(Capsule())
            .foregroundColor(.white)
    }
}

// MARK: - BreathingPatternSelector

private struct BreathingPatternSelector: View {
    @Binding var selectedPattern: BreathingPattern
    var isRunning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breathing Pattern")
                .font(.headline)
                .foregroundColor(.white)

            Text(selectedPattern.subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            // Single row, 4 equal-width chips
            HStack(spacing: 6) {
                ForEach(BreathingPattern.allCases) { pattern in
                    patternChip(for: pattern)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private func patternChip(for pattern: BreathingPattern) -> some View {
        let isSelected = selectedPattern == pattern

        return Button {
            guard !isRunning else { return }
            selectedPattern = pattern
        } label: {
            Text(pattern.title)
                .font(.subheadline.weight(.light))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 32) // 👈 equal width
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(
            Capsule()
                .fill(isSelected ? Color.white : Color.clear)
        )
        .overlay(
            Capsule()
                .stroke(
                    Color.white.opacity(isSelected ? 0 : 0.7),
                    lineWidth: 1
                )
        )
        .foregroundColor(
            isSelected
            ? Color.black                    // text on selected chip
            : Color.white.opacity(isRunning ? 0.7 : 0.95)
        )
        .opacity(isRunning ? 0.85 : 1.0)
    }
}

