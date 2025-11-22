//
//  PulsingBreathingCircle.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct PulsingBreathingCircle: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.4

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.5))
            .frame(width: 260, height: 260)
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: 40)
            .animation(
                .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 1.15
                opacity = 0.8
            }
    }
}

