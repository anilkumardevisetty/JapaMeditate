//
//  AudioManager.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/15/25.
//
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?

    func playMantra(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("Audio file missing: \(fileName)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Audio playback error: \(error)")
        }
    }
}
