//
//  AppPanel.swift
//  JapaMeditate
//
//  Created by Anilkumar Devisetty on 12/13/25.
//
import SwiftUI

struct AppPanel<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let cornerRadius: CGFloat
    private let fill: Color
    private let strokeOpacity: Double
    private let shadowOpacity: Double
    private let contentPadding: CGFloat
    private let content: Content

    init(
        cornerRadius: CGFloat = 32,
        fill: Color = .white,
        strokeOpacity: Double = 0.06,
        shadowOpacity: Double = 0.12,
        contentPadding: CGFloat = 14,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.strokeOpacity = strokeOpacity
        self.shadowOpacity = shadowOpacity
        self.contentPadding = contentPadding
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            content
                .padding(contentPadding)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(fill)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(strokeOpacity), lineWidth: 1)
                )
                .shadow(color: .black.opacity(shadowOpacity), radius: 18, y: 10)
                .frame(
                    maxWidth: panelWidth(for: geo.size.width),
                    alignment: .center
                )
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height / 2
                )
        }
    }

    private func panelWidth(for screenWidth: CGFloat) -> CGFloat {
        // iPad (regular width): center panel at ~55% width
        if hSizeClass == .regular {
            return min(screenWidth * 0.55, 640)
        }

        // iPhone: full width minus margins
        return screenWidth - 32
    }
}

