//
//  HomeStatCard.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct HomeStatCard: View {
    let title: String
    let value: String
    var icon: String? = nil
    var color: Color = .white.opacity(0.15)

    var body: some View {
        HStack(spacing: 16) {

            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

