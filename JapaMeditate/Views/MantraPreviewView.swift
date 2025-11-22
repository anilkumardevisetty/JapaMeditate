//
//  MantraPreviewView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import SwiftUI

struct MantraPreviewView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron

    let mantra: Mantra
    let customText: String

    var body: some View {
        ZStack {
            selectedTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Sanskrit
                    Text(mantra == .custom ? customText : mantra.rawValue)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text(mantra == .custom ? customText : mantra.transliteration)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Play Audio
//                    if let audioFile = mantra.audioFileName {
//                        Button {
//                            AudioManager.shared.playMantra(audioFile)
//                   	     } label: {
//                            Label("Play Audio", systemImage: "play.circle.fill")
//                                .font(.title2)
//                        }
//                        .padding(.top)
//                    }
                }
                .padding()
            }
            .navigationTitle(mantra.title)
        }
    }
}

