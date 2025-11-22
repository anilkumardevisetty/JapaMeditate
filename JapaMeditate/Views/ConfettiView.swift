import SwiftUI

struct ConfettiView: View {
    @Binding var trigger: Bool
    
    let colors: [Color] = [
        .white, .pink, .blue, .purple, .green, .cyan, .yellow
    ]
    
    var body: some View {
        ZStack {
            if trigger {
                ForEach(0..<40, id: \.self) { i in
                    ConfettiParticle(color: colors.randomElement()!)
                }
            }
        }
        .allowsHitTesting(false)
        .animation(.easeOut(duration: 0.9), value: trigger)
    }
}

struct ConfettiParticle: View {
    let color: Color
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 6, height: 12)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                let randomX = CGFloat.random(in: -120...120)
                let randomY = CGFloat.random(in: 150...300)
                let randomRot = Double.random(in: 90...720)
                
                withAnimation(.easeOut(duration: 1.2)) {
                    xOffset = randomX
                    yOffset = randomY
                    rotation = randomRot
                }
            }
    }
}
