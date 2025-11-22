//
//  ThemeView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI

struct ThemeView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    var body: some View {
        List {
            ForEach(AppTheme.allCases) { theme in
                HStack(spacing: 16) {

                    // Theme preview circle
                    Circle()
                        .fill(theme.background)
                        .frame(width: 45, height: 45)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )

                    Text(theme.title)
                        .font(.headline)

                    Spacer()

                    if theme == selectedTheme {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedTheme = theme }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Themes")
    }
}
