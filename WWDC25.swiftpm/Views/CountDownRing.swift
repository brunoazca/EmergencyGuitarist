//
//  CountDownRing.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//
import SwiftUI

struct CountdownRing: View {
    @State private var progress: CGFloat = 1.0 // Começa cheio
    @State private var duration: TimeInterval = 3 // Duração da animação
    @State private var isPlay = false
    @State private var color = Color.blue
    @State private var accumulatedInterval: CGFloat = 0

    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var soundPlayer = SoundPlayer()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .opacity(0.6)
                .shadow(color: .black, radius: 30, x: 0, y: 0)
                .frame(width: isIPad ? 220 : 110, height: isIPad ? 220 : 110)
                .overlay {
                    ZStack {
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)
                            let radius = min(size.width, size.height) / 2 - 10
                            let startAngle: Angle = .degrees(-90)
                            let endAngle: Angle = .degrees(Double(-90) + (360 * Double(progress)))

                            var path = Path()
                            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

                            context.stroke(path, with: .color(color), lineWidth: isIPad ? 20 : 10)
                        }
                        if !isPlay {
                            Text("\(Int(ceil(progress * duration)))")
                                .foregroundStyle(.white)
                                .font(.system(size: isIPad ? 50 : 25))
                                .fontWeight(.bold)
                        } else {
                            Text("PLAY!")
                                .foregroundStyle(.white)
                                .font(.system(size: isIPad ? 50 : 25))
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                }
        }
        .onAppear {
            startCountdown()
        }
    }

    func startCountdown() {
        progress = 1.0
        accumulatedInterval = 0
        soundPlayer.playSound("Metronome") // Primeira batida

        runCountdown()
    }

    func runCountdown() {
        let step: CGFloat = 0.01 // Pequeno decremento progressivo
        let interval: TimeInterval = duration * step // Tempo de cada atualização

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if self.progress > 0 {
                withAnimation(.linear(duration: interval)) {
                    self.progress -= step
                }
                
                self.accumulatedInterval += interval
                if self.accumulatedInterval >= 1 {
                    self.accumulatedInterval = 0
                    if !self.isPlay {
                        self.soundPlayer.playSound("Metronome")
                    }
                }

                self.runCountdown() // Chama recursivamente até terminar
            } else {
                self.isPlay.toggle()
                if self.isPlay {
                    self.duration = 2
                    self.color = .green
                } else {
                    AppLibrary.Instance.currentChordIndex += 1
                    if AppLibrary.Instance.chordSequence.count <= AppLibrary.Instance.currentChordIndex {
                        AppLibrary.Instance.currentChordIndex = 0
                    }
                    AppLibrary.Instance.currentChord = AppLibrary.Instance.chordSequence[AppLibrary.Instance.currentChordIndex]
                    self.duration = 3
                    self.color = .blue
                }
                self.startCountdown()
            }
        }
    }
}

#Preview {
    CountdownRing()
}
