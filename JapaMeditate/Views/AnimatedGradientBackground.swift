//
//  AnimatedGradientBackground.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.4),
                Color.blue.opacity(0.4),
                Color.black.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .scaleEffect(animate ? 1.15 : 1.0)        // pulse
        .animation(
            .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
            value: animate
        )
        .onAppear {
            animate = true
        }
        .ignoresSafeArea()
    }
}
