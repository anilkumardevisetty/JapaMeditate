import SwiftUI
import UIKit
import Combine

struct CounterView: View {
    @StateObject private var viewModel = ChantViewModel()
    @StateObject private var confettiManager = ConfettiManager()

    // MARK: - Settings
    @AppStorage(SettingsKeys.mantra)
    private var selectedMantra: String = Mantra.omNamahShivaya.rawValue

    @AppStorage(SettingsKeys.customMantra)
    private var customMantraText: String = ""

    @AppStorage(SettingsKeys.target)
    private var targetCount: Int = 108

    @AppStorage(SettingsKeys.wordAnimationEnabled)
    private var wordAnimationEnabled: Bool = false

    @AppStorage("selectedTheme")
    private var selectedTheme: AppTheme = .saffron

    // MARK: - Word animation state
    @State private var currentWord: String = ""
    @State private var showWord: Bool = false
    @State private var isAnimatingMantra: Bool = false
    @State private var currentWordIndex: Int = 0

    // MARK: - Mala (108 beads) state
    @State private var beadStates: [Bool] = Array(repeating: false, count: 108)
    
    // MARK: - Mantra text helpers

    var currentDisplayedMantra: String {
        let mantraEnum = Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
        return mantraEnum == .custom ? customMantraText : mantraEnum.rawValue
    }
    
    var currentTransliteration: String {
        let mantraEnum = Mantra(rawValue: selectedMantra) ?? .omNamahShivaya

        if mantraEnum == .custom {
            return UserDefaults.standard.string(forKey: "customTransliteration") ?? ""
        }

        return mantraEnum.transliteration
    }

    var currentMantra: Mantra {
        Mantra(rawValue: selectedMantra) ?? .omNamahShivaya
    }

    var mantraWords: [String] {
        let cleaned = currentDisplayedMantra
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
            .split(separator: " ")
            .map { String($0) }
    }

    // MARK: - Bead placement around circle

    func positionForBead(in size: CGFloat, index: Int, total: Int = 108) -> CGPoint {
        let angle = (Double(index) / Double(total)) * 2 * Double.pi - Double.pi / 2
        let radius = Double(size) * 0.46

        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack {
            // MARK: App background (white)
            Color.white
                .ignoresSafeArea()

            // MARK: Completion overlay
            if viewModel.justCompleted {
                ZStack {
                    selectedTheme.background
                        .opacity(0.9)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        Text("🙏 Congratulations! 🙏")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Text("You completed 108 chants.\nMay peace and blessings be with you.")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.center)

                        Button(action: {
                            withAnimation {
                                viewModel.justCompleted = false
                            }
                        }) {
                            Text("Continue")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                        }

                        StyledBanner()
                            .padding(.top, 8)
                    }
                    .padding()
                }
                .transition(.opacity)
                .zIndex(999)
            }

            VStack(spacing: 16) {
                Spacer(minLength: 8)

                // MARK: Tile 1 – Intro
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("JAPA MODE")
                            .font(.caption2.smallCaps())
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        if viewModel.count > 0 {
                            Text("\(viewModel.count)/\(viewModel.total)")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                    }

                    Text("Chant with focus and devotion.")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text("Tap the circle with ॐ to count each mantra.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.95))
                }
                .padding(16)
                .background(selectedTheme.background)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                // MARK: Tile 2 – Circle + ॐ + beads
                ZStack {
                    selectedTheme.background
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)

                    VStack(spacing: 12) {
                        // Word animation overlay (above circle)
                        if wordAnimationEnabled && showWord {
                            Text(currentWord)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white.opacity(0.98))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.center)
                                .scaleEffect(showWord ? 1 : 0.6)
                                .opacity(showWord ? 1 : 0)
                                .transition(.opacity.combined(with: .scale))
                                .zIndex(50)
                        }

                        // Counter Circle + Mala + centered ॐ
                        GeometryReader { geo in
                            let size = min(geo.size.width, geo.size.height)

                            ZStack {
                                // ॐ watermark, centered
                                Text("ॐ")
                                    .font(.system(size: size * 0.8, weight: .bold))
                                    .foregroundColor(.white.opacity(0.08))

                                // 1) Inner background ring
                                Circle()
                                    .stroke(
                                        Color.white.opacity(0.25),
                                        style: StrokeStyle(lineWidth: 14)
                                    )

                                // 🚫 NO progress Circle() here anymore

                                // 2) Beads ring – this is now the ONLY progress indicator
                                ForEach(0..<108, id: \.self) { i in
                                    // if you want beads slightly outside the circle, tweak multiplier
                                    let point = positionForBead(in: size * 1.05, index: i)

                                    Circle()
                                        .fill(
                                            beadStates[i]
                                            ? Color.white                         // lit / completed
                                            : Color.white.opacity(0.25)           // not yet counted
                                        )
                                        .frame(
                                            width: beadStates[i] ? 10 : 8,
                                            height: beadStates[i] ? 10 : 8
                                        )
                                        .shadow(
                                            color: beadStates[i]
                                                ? Color.white.opacity(0.4)
                                                : .clear,
                                            radius: beadStates[i] ? 4 : 0
                                        )
                                        .offset(x: point.x, y: point.y)
                                }

                                // 3) Count + mantra text (unchanged)
                                VStack(spacing: 8) {
                                    Text("\(viewModel.count)")
                                        .font(.system(size: 52, weight: .bold))
                                        .foregroundColor(.white)

                                    Text("/ \(viewModel.total)")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.9))

                                    Text("Tap anywhere on this tile to count")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            .frame(width: size * 0.90, height: size * 0.90)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        }
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)


                        // ✅ Haptics text is now *outside* the circle, at bottom of tile
                        Text("Haptics at 27 • 54 • 80 • 108")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(18)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap()
                }


                // MARK: Tile 3 – Mantra preview
                VStack(alignment: .center, spacing: 10) {
                    Text("Mantra Preview")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(currentTransliteration.isEmpty ? "No mantra set" : currentTransliteration)
                        .font(.footnote)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        NavigationLink(
                            destination: MantraPreviewView(
                                mantra: Mantra(rawValue: selectedMantra) ?? .omNamahShivaya,
                                customText: customMantraText
                            )
                        ) {
                            Text("Preview Mantra")
                                .modifier(CounterActionChip())
                        }

                        NavigationLink(destination: SettingsView()) {
                            Text("Change Mantra")
                                .modifier(CounterActionChip())
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(selectedTheme.background)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.10), radius: 10, y: 5)

                // MARK: Tile 4 – Buttons / actions (aligned)
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.reset()
                            resetBeads()
                        }) {
                            Text("Reset Count")
                                .modifier(CounterActionChip())
                        }
                    }
                }
                .padding(16)
                .background(selectedTheme.background)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.10), radius: 10, y: 5)

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }

        // MARK: Sync target count with settings
        .onAppear {
            viewModel.total = targetCount
            syncBeadsWithCurrentCount()
        }
        .onChange(of: targetCount) { newValue in
            viewModel.total = newValue
            viewModel.reset()
            resetBeads()
        }
    }

    // MARK: - Tap Handling

    func handleTap() {
        if !wordAnimationEnabled {
            viewModel.increment()
            updateBeadsAfterIncrement()

            if viewModel.count == 108 {
                if UserDefaults.standard.bool(forKey: SettingsKeys.hapticsEnabled) {
                    HapticsManager.shared.finalTriplePulse()
                }

                viewModel.reset()
                resetBeads()
                viewModel.completeOneRound()
            }

            return
        }

        guard !isAnimatingMantra else { return }

        isAnimatingMantra = true
        currentWordIndex = 0
        runMantraAnimation()
    }

    // MARK: - Word-by-word mantra animation

    func runMantraAnimation() {
        let words = mantraWords
        let total = words.count

        if total == 0 {
            isAnimatingMantra = false
            return
        }

        currentWord = words[currentWordIndex]

        withAnimation(.easeOut(duration: 0.25)) {
            showWord = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
        viewModel.increment()
        updateBeadsAfterIncrement()

        if viewModel.count == 108 {
            viewModel.reset()
            resetBeads()
            viewModel.completeOneRound()
        }

        isAnimatingMantra = false
    }

    // MARK: - Bead helpers

    func syncBeadsWithCurrentCount() {
        var newStates = Array(repeating: false, count: 108)
        let capped = max(0, min(viewModel.count, 108))

        if capped > 0 {
            for i in 0..<capped {
                newStates[i] = true
            }
        }

        beadStates = newStates
    }

    func updateBeadsAfterIncrement() {
        let c = viewModel.count
        if c > 0 && c <= 108 {
            beadStates[c - 1] = true
        }
    }

    func resetBeads() {
        beadStates = Array(repeating: false, count: 108)
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CounterView()
        }
    }
}

private struct CounterActionChip: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.20))
            .clipShape(Capsule())
            .foregroundColor(.white)
    }
}
