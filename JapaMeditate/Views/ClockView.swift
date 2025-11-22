//
//  ClockView.swift
//  JapaMeditate
//
//  Created by Anilkumar Devisetty on 11/18/25.
//
import SwiftUI
import Combine

struct ClockView: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(formattedTime(now))
            .font(.headline)
            .foregroundColor(.white)
            .onReceive(timer) { value in
                now = value
            }
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d • h:mm a"  // Example: Tue, Jan 14 • 7:42 PM
        return formatter.string(from: date)
    }
}

