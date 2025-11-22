//
//  CounterView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//

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
    private var wordAnimationEnabled: Bool = true

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

    /// This is the mantra currently selected, resolving custom vs preset.
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

    /// Split the mantra into words for word-by-word animation.
    var mantraWords: [String] {
        let cleaned = currentDisplayedMantra
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
            .split(separator: " ")
            .map { String($0) }
    }

    // MARK: - Bead placement around circle

    /// Returns the x/y offset for bead i out of total around a circle of given size.
    func positionForBead(in size: CGFloat, index: Int, total: Int = 108) -> CGPoint {
        let angle = (Double(index) / Double(total)) * 2 * Double.pi - Double.pi / 2
        let radius = Double(size) * 0.46

        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return CGPoint(x: x, y: y)
    }

    var body: some View {
        ZStack {
            if viewModel.justCompleted {
                VStack(spacing: 16) {
                    Text("🙏 Congratulations! 🙏")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("You completed 108 chants.\nMay peace and blessings be with you.")
                        .font(.headline)
                        //.foregroundColor(.white.opacity(0.9))
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
                    StyledBanner() // 👈 looks like part of the UI
                            .padding(.bottom, 10)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.45))
                .transition(.opacity)
                .zIndex(999)
            }

            
            // MARK: Background gradient
            selectedTheme.background
                .ignoresSafeArea()

            // MARK: Background ॐ
            GeometryReader { geo in
                Text("ॐ")
                    .font(.system(size: geo.size.width * 0.6, weight: .bold))
                    .foregroundColor(.white.opacity(0.1))
                    .rotationEffect(.degrees(0))
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height * 0.42
                    )
            }
            .allowsHitTesting(false)

            // MARK: Word animation overlay (above circle)
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
                    Text("Japa Mode")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Japa Mantra Chant Counter")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer(minLength: 10)

                // MARK: Counter Circle + Mala
                ZStack {
                    GeometryReader { geo in
                        let size = min(geo.size.width, geo.size.height)

                        ZStack {
                            // 1) Background ring
                            Circle()
                                .stroke(
                                    Color.white.opacity(0.15),
                                    style: StrokeStyle(lineWidth: 16)
                                )

                            // 2) Progress ring (based on viewModel.progress)
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(
                                    selectedTheme.ringGradient,
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut(duration: 0.2), value: viewModel.progress)

                            // 3) Full 108-bead mala ring
                            ForEach(0..<108, id: \.self) { i in
                                let point = positionForBead(in: size, index: i)

                                Circle()
                                    .fill(beadStates[i]
                                          ? Color.white
                                          : Color.white.opacity(0.25))
                                    .frame(
                                        width: beadStates[i] ? 10 : 8,
                                        height: beadStates[i] ? 10 : 8
                                    )
                                    .shadow(
                                        color: beadStates[i]
                                            ? Color.white.opacity(0.4)
                                            : Color.clear,
                                        radius: beadStates[i] ? 4 : 0
                                    )
                                    .offset(x: point.x, y: point.y)
                            }

                            // 4) Count + mantra text
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
                                    .padding(.top, 8)

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
                Text(currentTransliteration)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
                //Spacer()
                
                // MARK: Reset
                Button(action: {
                    viewModel.reset()
                    resetBeads()
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

                // MARK: Quick Actions
                HStack(spacing: 20) {

                    NavigationLink(destination:
                        MantraPreviewView(
                            mantra: Mantra(rawValue: selectedMantra) ?? .omNamahShivaya,
                            customText: customMantraText
                        )
                    ) {
                        Text("Preview Mantra")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                    }

                    NavigationLink(destination: SettingsView()) {
                        Text("Change Mantra")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                    }
                }
                Text("Haptics at 27 • 54 • 80 • 108")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                .padding(.top, 4)

                Spacer(minLength: 30)
            }
            .padding(.horizontal, 24)
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

    /// Called when the user taps the main counter circle.
    func handleTap() {
        // CASE 1: Word animation is OFF → direct count
        if !wordAnimationEnabled {
            viewModel.increment()
            updateBeadsAfterIncrement()

            // Detect full 108-round completion
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

        // CASE 2: Word animation is ON → full mantra animation per tap
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

        // Word display duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.25)) {
                showWord = false
            }

            currentWordIndex += 1

            if currentWordIndex >= total {
                // Finished full mantra
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    finishMantra()
                }
            } else {
                // Next word
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    runMantraAnimation()
                }
            }
        }
    }

    func finishMantra() {
        // Full mantra completed once → count as 1
        viewModel.increment()
        updateBeadsAfterIncrement()

        // If that takes us to 108 → one round complete
        if viewModel.count == 108 {
            viewModel.reset()
            resetBeads()
            viewModel.completeOneRound()
        }

        isAnimatingMantra = false
    }

    // MARK: - Bead helpers

    /// Sets beads[0...count-1] = true
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

    /// After incrementing count by 1, light up the new bead.
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

// MARK: - Preview

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CounterView()
        }
    }
}
