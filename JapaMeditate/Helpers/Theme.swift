//
//  Theme.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case saffron
    case mandalaPurple
    case amoledBlack
    case calmBlue
    case sunrise

    var id: String { self.rawValue }
}


extension AppTheme {

    var title: String {
        switch self {
        case .saffron: return "Saffron Spiritual"
        case .mandalaPurple: return "Mandala Purple"
        case .amoledBlack: return "AMOLED Black"
        case .calmBlue: return "Calm Blue Meditation"
        case .sunrise: return "Sunrise Minimal"
        }
    }

    // Background gradients for each theme
    var background: LinearGradient {
        switch self {

        case .saffron:
            return LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.58, blue: 0.18),
                    Color(red: 0.76, green: 0.23, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .mandalaPurple:
            return LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.20, blue: 0.55),
                    Color(red: 0.60, green: 0.45, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .amoledBlack:
            return LinearGradient(
                colors: [Color.black, Color.black],
                startPoint: .top,
                endPoint: .bottom
            )

        case .calmBlue:
            return LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.55, blue: 0.75),
                    Color(red: 0.05, green: 0.25, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .sunrise:
            return LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.80, blue: 0.65),
                    Color(red: 1.00, green: 0.60, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // Accent ring color(s)
    var ringGradient: AngularGradient {
        switch self {

        case .saffron:
            return AngularGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.84, blue: 0.46),
                    Color(red: 0.97, green: 0.72, blue: 0.40),
                    Color(red: 1.0, green: 0.84, blue: 0.46)
                ]),
                center: .center
            )

        case .mandalaPurple:
            return AngularGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.9),
                    Color.orange.opacity(0.8),
                    Color.white.opacity(0.9)
                ]),
                center: .center
            )

        case .amoledBlack:
            return AngularGradient(
                gradient: Gradient(colors: [
                    Color.yellow.opacity(0.9),
                    Color.orange.opacity(0.7),
                    Color.yellow.opacity(0.9)
                ]),
                center: .center
            )

        case .calmBlue:
            return AngularGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.cyan.opacity(0.8)
                ]),
                center: .center
            )

        case .sunrise:
            return AngularGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.orange.opacity(0.85)
                ]),
                center: .center
            )
        }
    }
}

