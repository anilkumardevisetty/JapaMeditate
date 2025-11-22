import SwiftUI

struct CounterView_BackUp: View {
    @StateObject private var viewModel = ChantViewModel()

    // MARK: Settings
    @AppStorage(SettingsKeys.mantra) private var selectedMantra: String = Mantra.omNamahShivaya.rawValue
    @AppStorage(SettingsKeys.customMantra) private var customMantraText: String = ""
    @AppStorage(SettingsKeys.target) private var targetCount: Int = 108
    @AppStorage(SettingsKeys.wordAnimationEnabled) private var wordAnimationEnabled: Bool = true

    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    // MARK: UI states
    @State private var isPressed: Bool = false
    @State private var currentWord: String = ""
    @State private var showWord: Bool = false
    @State private var isAnimatingMantra: Bool = false
    @State private var currentWordIndex: Int = 0
    @State private var beadVisible: Bool = false
    @State private var beadStates: [Bool] = Array(repeating: false, count: 108)


    // MARK: Bead animation
    @State private var beadPosition: CGPoint = .zero

    // MARK: Displayed mantra
    var currentDisplayedMantra: String {
        let mantraEnum = Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
        return mantraEnum == .custom ? customMantraText : mantraEnum.rawValue
    }

    // MARK: Split into words
    var mantraWords: [String] {
        let cleaned = currentDisplayedMantra
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
            .split(separator: " ")
            .map { String($0) }
    }

    // MARK: Bead circle position calculator
    func positionForBead(in size: CGFloat, index: Int, total: Int = 108) -> CGPoint {
        let angle = (Double(index) / Double(total)) * 2 * Double.pi - Double.pi / 2
        let radius = Double(size) * 0.46

        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack {

            // MARK: Background gradient
            selectedTheme.background
                .ignoresSafeArea()

            // MARK: Background ॐ
            GeometryReader { geo in
                Text("ॐ")
                    .font(.system(size: geo.size.width * 0.9, weight: .bold))
                    .foregroundColor(.white.opacity(0.04))
                    .rotationEffect(.degrees(-15))
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height * 0.32
                    )
            }
            .allowsHitTesting(false)

            // MARK: Word fade overlay
            if wordAnimationEnabled && showWord {
                Text(currentWord)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.horizontal, 12)
                    .multilineTextAlignment(.center)
                    .scaleEffect(showWord ? 1 : 0.6)
                    .opacity(showWord ? 1 : 0)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(50)
                    .offset(y: -180)
            }

            VStack(spacing: 24) {

                // MARK: Title
                VStack(spacing: 4) {
                    Text("Japa 108")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Mantra Chant Counter")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer().frame(height: 10)

                // MARK: Counter Circle
                ZStack {
                    GeometryReader { geo in
                        let size = min(geo.size.width, geo.size.height)

                        ZStack {

                            // Background ring
                            Circle()
                                .stroke(
                                    Color.white.opacity(0.15),
                                    style: StrokeStyle(lineWidth: 16)
                                )

                            // Progress ring
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(
                                    selectedTheme.ringGradient,
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut(duration: 0.2), value: viewModel.progress)

                            // MARK: Bead
                            if beadVisible {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 16, height: 16)
                                    .shadow(color: .white.opacity(0.7), radius: 4)
                                    .offset(x: beadPosition.x, y: beadPosition.y)
                                    .animation(.easeOut(duration: 0.25), value: beadPosition)
                            }

                            // MARK: Count + Mantra
                            VStack(spacing: 8) {
                                Text("\(viewModel.count)")
                                    .font(.system(size: 52, weight: .bold))
                                    .foregroundColor(.white)

                                Text("/ \(viewModel.total)")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.85))

                                Text(currentDisplayedMantra)
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text("Tap to count")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.75))
                            }
                        }
                        .frame(width: size * 0.85, height: size * 0.85)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                }
                .frame(height: 330)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap()
                }

                Spacer()

                // MARK: Reset
                Button(action: {
                    viewModel.reset()
                    beadVisible = false
                }) {
                    Text("Reset Count")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(Color.white.opacity(0.15))
                        )
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                }

                Text("Haptics at 27 • 54 • 80 • 108")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))

                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 24)
        }

        // MARK: Toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ThemeView()) {
                    Image(systemName: "paintpalette")
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: StatsView()) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(.white)
                }
            }
        }

        // MARK: Sync settings
        .onAppear {
            viewModel.total = targetCount
            let index = viewModel.count % 108
            beadPosition = positionForBead(in: 280, index: index)
            
            NotificationManager.shared.requestPermission()
        }
        .onChange(of: targetCount) { _ in
            viewModel.total = targetCount
            viewModel.reset()
            beadPosition = .zero
        }
    }


    // MARK: TAP HANDLER
    func handleTap() {
        // ------------------------------------------
        // CASE 1: Word animation is OFF
        // ------------------------------------------
        if !wordAnimationEnabled {
            incrementBead()
            viewModel.increment()
            
            // 🔥 Detect one full round of 108
            if viewModel.count == 108 {
                viewModel.reset()
                viewModel.completeOneRound()
            }
            
            return
        }
        
        // ------------------------------------------
        // CASE 2: Word animation is ON (full animation)
        // ------------------------------------------
        guard !isAnimatingMantra else { return }
        
        isAnimatingMantra = true
        currentWordIndex = 0
        runMantraAnimation()
    }


    // MARK: Mantra Animation
    func runMantraAnimation() {
        let words = mantraWords
        let total = words.count
        if total == 0 { return }

        currentWord = words[currentWordIndex]

        withAnimation(.easeOut(duration: 0.25)) {
            showWord = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {  // word duration
            withAnimation(.easeOut(duration: 0.25)) {
                showWord = false
            }

            currentWordIndex += 1

            if currentWordIndex >= total {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    finishMantra()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    runMantraAnimation()
                }
            }
        }
    }

    func finishMantra() {
        incrementBead()
        viewModel.increment()
        if viewModel.count == 108 {
            viewModel.reset()      // reset counter for next round
            viewModel.completeOneRound()
        }

        isAnimatingMantra = false
    }

    // MARK: Bead Movement
    func incrementBead() {
        // Show bead on first use
        beadVisible = true

        let index = viewModel.count % 108
        beadPosition = positionForBead(in: 280, index: index)
    }

}


// MARK: Preview
struct CounterView_Previews_back: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CounterView()
        }
    }
}
