//
//  LargeActionButton.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/16/25.
//
import SwiftUI

struct LargeActionButton: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.title3.bold())
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
    }
}

