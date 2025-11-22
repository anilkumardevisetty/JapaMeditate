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
    @State private var showPicker: Bool = false
    @State private var selectedSessionLength: Int = 2

    // Breath timing (seconds)
    let inhaleDuration: Double = 4
    let holdDuration: Double = 2
    let exhaleDuration: Double = 4

    // Minutes options: 2 → 20 mins
    let sessionOptions = Array(stride(from: 2, through: 20, by: 2))

    var formattedRemainingTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            selectedTheme.background.ignoresSafeArea()
            
            // MARK: Background ॐ
            GeometryReader { geo in
                Text("ॐ")
                    .font(.system(size: geo.size.width * 0.3, weight: .bold))
                    .foregroundColor(.white.opacity(0.1))
                    .rotationEffect(.degrees(0))
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height * 0.52
                    )
            }
            .allowsHitTesting(false)

            VStack(spacing: 25) {

                // MARK: Title
                Text("Meditation Mode")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 10)

                Text("Breath In • Hold • Breath Out")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                // MARK: Session Selector
                VStack(spacing: 8) {
                    HStack {
                        Text("Session Length:")
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Button(action: { showPicker.toggle() }) {
                            HStack {
                                Text("\(selectedSessionLength) min")
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Dropdown
                    if showPicker {
                        VStack(spacing: 6) {
                            ForEach(sessionOptions, id: \.self) { num in
                                Button("\(num) min") {
                                    selectedSessionLength = num
                                    showPicker = false
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                // MARK: Remaining Time
                if isRunning {
                    Text("Remaining: \(formattedRemainingTime)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // MARK: Main Circle + Phase Text + Counter
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: animationDuration()), value: circleScale)

                    VStack(spacing: 6) {
                        Text(phase.rawValue)
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .opacity(phase == .idle ? 0 : 1)

                        if isRunning {
                            Text("Cycles: \(cycleCount)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }

                Spacer()

                // MARK: Start / End / Completed Buttons
                if !isRunning && !meditationCompleted {
                    Button(action: startMeditation) {
                        Text("Start")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Capsule())
                    }

                } else if isRunning {
                    Button(action: stopMeditation) {
                        Text("End")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Capsule())
                    }

                } else if meditationCompleted {
                    VStack(spacing: 12) {
                        Text("Session Complete")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        StyledBanner()
                                .padding(.bottom, 10)

                        Button("Done") {
                            dismiss()
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.8))
                        .clipShape(Capsule())
                    }
                }
                Spacer(minLength: 40)
            }
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
                meditationCompleted = true
                stopMeditation()
                recordCompletedMeditationSession()
                return
            }


            countdownTimer()
        }
    }
    
    // MARK: - Stats recording

    func recordCompletedMeditationSession() {
        var stats = JapaStatsManager.shared.load()

        // date key like "2025-11-16"
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let today = f.string(from: Date())

        stats.lifetimeMeditationSessions += 1
        stats.lifetimeMeditationMinutes += selectedSessionLength
        stats.dailyMeditationSessions[today, default: 0] += 1
        stats.lastMeditationDate = Date()

        JapaStatsManager.shared.save(stats)
    }

    
    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
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

                    runBreathingCycle()
                }
            }
        }
    }
}
