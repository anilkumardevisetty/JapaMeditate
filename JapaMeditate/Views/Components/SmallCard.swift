//
//  SmallCard.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct SmallCard: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.footnote)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
    }
}

