//
//  ConfettiManager.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI
import Combine

class ConfettiManager: ObservableObject {
    @Published var trigger: Bool = false
    
    func fire() {
        trigger.toggle()   // just flip value to trigger animation
    }
}

