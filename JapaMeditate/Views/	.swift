import SwiftUI
import CoreHaptics

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    // MARK: Breathing State
    enum BreathPhase: String {
        case inhale = "Breath In"
        case hold = "Hold"
        case exhale = "Breath Out"
        case idle = ""
    }

    @State private var phase: BreathPhase = .idle
    @State private var circleScale: CGFloat = 1.0
    @State private var isRunning: Bool = false
    @State private var cycleCount: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var meditationCompleted: Bool = false

    // Session length picker
    @State private var showPicker: Bool = false
    @State private var selectedSessionLength: Int = 2

    // To finish current breath cycle when time hits 0
    @State private var shouldEndAtCycleCompletion: Bool = false

    // Breath timing (seconds)
    let inhaleDuration: Double = 4
    let holdDuration: Double = 2
    let exhaleDuration: Double = 4

    // Minutes options: 2 → 20 mins
    let sessionOptions = Array(stride(from: 1, through: 20, by: 1))

    var formattedRemainingTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // App background
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 8)

                // MARK: Tile 1 – Intro
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

                // MARK: Tile 2 – Breath circle + ॐ + phase
                ZStack {
                    selectedTheme.background
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                    VStack(spacing: 12) {
                        GeometryReader { geo in
                            let size = min(geo.size.width, geo.size.height)

                            ZStack {
                                // ॐ watermark
                                Text("ॐ")
                                    .font(.system(size: size * 0.6, weight: .bold))
                                    .foregroundColor(.white.opacity(0.08))

                                // Soft breathing circle
                                Circle()
                                    .fill(Color.white.opacity(0.20))
                                    .frame(width: size * 0.65, height: size * 0.65)
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
                                    } else if !meditationCompleted {
                                        Text("Tap Start to begin guided breathing.")
                                            .font(.footnote)
                                            .foregroundColor(.white.opacity(0.9))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 24)
                                    }
                                }
                            }
                            .frame(width: size, height: size)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        }
                        .frame(height: 260)
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

                // MARK: Tile 3 – Session length selection
                VStack(alignment: .leading, spacing: 10) {
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

                // MARK: Tile 4 – Controls
                VStack(spacing: 12) {
                    if !isRunning && !meditationCompleted {
                        Button(action: startMeditation) {
                            Text("Start Meditation")
                                .modifier(MeditationPrimaryButton())
                        }

                    } else if isRunning {
                        Button(action: stopMeditation) {
                            Text("End Session")
                                .modifier(MeditationPrimaryButton())
                        }

                    } else if meditationCompleted {
                        VStack(spacing: 12) {
                            Text("Session Complete")
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            StyledBanner()
                                .padding(.bottom, 4)

                            Button(action: { dismiss() }) {
                                Text("Done")
                                    .modifier(MeditationPrimaryButton())
                            }
                        }
                    }
                }
                .padding(16)
                .background(selectedTheme.background)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
                .onChange(of: meditationCompleted) { newValue in
                    if newValue == true {
                        playCompletionHaptics()
                    }
                }

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        // Wheel-style picker sheet
        .sheet(isPresented: $showPicker) {
            VStack(spacing: 16) {
                Text("Session Length")
                    .font(.headline)
                    .padding(.top, 16)

                Picker("Session Length", selection: $selectedSessionLength) {
                    ForEach(sessionOptions, id: \.self) { num in
                        Text("\(num) minutes")
                            .tag(num)
                    }
                }
                .pickerStyle(.wheel)          // iOS clock-style
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
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            stopMeditation()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Animation Duration
    func animationDuration() -> Double {
        switch phase {
        case .inhale: return inhaleDuration
        case .hold: return holdDuration
        case .exhale: return exhaleDuration
        case .idle: return 0.1
        }
    }

    // MARK: - Start Meditation
    func startMeditation() {
        cycleCount = 0
        meditationCompleted = false
        remainingSeconds = selectedSessionLength * 60
        shouldEndAtCycleCompletion = false

        isRunning = true

        runBreathingCycle()
        countdownTimer()
    }

    // MARK: - Stop Meditation
    func stopMeditation() {
        isRunning = false
        phase = .idle
        circleScale = 1.0

        MeditationHapticsManager.shared.stopContinuous()
    }

    // MARK: - Countdown Timer
    func countdownTimer() {
        guard isRunning else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard isRunning else { return }

            remainingSeconds -= 1

            if remainingSeconds <= 0 {
                // Time is up → let current breath cycle finish,
                // then we'll end at the end of exhale.
                shouldEndAtCycleCompletion = true
                return
            }

            countdownTimer()
        }
    }
    
    // MARK: - Stats recording

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

    // MARK: - Breathing Logic
    func runBreathingCycle() {
        guard isRunning else { return }

        // INHALE
        phase = .inhale
        circleScale = 1.35
        MeditationHapticsManager.shared.startContinuous()

        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard isRunning else { return }

            // HOLD
            phase = .hold
            circleScale = 1.4
            MeditationHapticsManager.shared.stopContinuous()

            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                guard isRunning else { return }

                // EXHALE
                phase = .exhale
                circleScale = 0.9
                MeditationHapticsManager.shared.startContinuous()

                DispatchQueue.main.asyncAfter(deadline: .now() + exhaleDuration) {
                    guard isRunning else { return }

                    MeditationHapticsManager.shared.stopContinuous()
                    cycleCount += 1

                    // If time has finished, end gracefully at end of this cycle
                    if shouldEndAtCycleCompletion || remainingSeconds <= 0 {
                        meditationCompleted = true
                        stopMeditation()
                        recordCompletedMeditationSession()
                    } else {
                        runBreathingCycle()
                    }
                }
            }
        }
    }
}

private func playCompletionHaptics() {
    Task { @MainActor in
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()

        // 10 short pulses
        for _ in 0..<10 {
            generator.impactOccurred()
            try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 sec between pulses
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
