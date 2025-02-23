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
    @State private var accumulatedInterval: CGFloat = 0
    @ObservedObject var gameState: GameState

    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var soundPlayer = SoundPlayer()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .opacity(0.6)
                .foregroundStyle(.black)
                .shadow(color: .black, radius: 30, x: 0, y: 0)
                .frame(width: isIPad ? 180 : 110, height: isIPad ? 180 : 110)
                .overlay {
                    ZStack {
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)
                            let radius = min(size.width, size.height) / 2 - 10
                            let startAngle: Angle = .degrees(-90)
                            let endAngle: Angle = .degrees(Double(-90) + (360 * Double(progress)))

                            var path = Path()
                            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

                            context.stroke(path, with: .color(gameState.currentChordColor.opacity(gameState.shouldPlay ? 1 : 0.5)), lineWidth: isIPad ? 20 : 10)
                        }
                        if !gameState.shouldPlay {
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
            gameState.shouldPlay = false

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

        DispatchQueue.global(qos: .userInitiated).async { // Rodando em uma thread separada
            while self.progress > 0 {
                let startTime = CFAbsoluteTimeGetCurrent() // Marca o tempo inicial
                
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: interval)) {
                        self.progress -= step
                    }
                }

                self.accumulatedInterval += interval
                if self.accumulatedInterval >= 1 {
                    self.accumulatedInterval = 0
                    if !self.gameState.shouldPlay {
                        self.soundPlayer.playSound("Metronome")
                    }
                }

                let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime // Calcula o tempo decorrido
                let sleepTime = max(0, interval - elapsedTime) // Ajusta para manter precisão
                
                usleep(useconds_t(sleepTime * 1_000_000)) // Aguarda sem sobrecarregar a CPU
            }

            DispatchQueue.main.async {
                self.gameState.shouldPlay.toggle()
                if self.gameState.shouldPlay {
                    self.duration = 2
                } else {
                    gameState.currentChordIndex += 1
                    if gameState.currentChordIndex + 1 <= gameState.challengeChordSequence.count{
                        gameState.currentChord = gameState.challengeChordSequence[gameState.currentChordIndex]
                    }
                    self.duration = 3
                }
                if(gameState.showMetronome){
                    self.startCountdown()
                }
            }
        }
    }

}

#Preview {
    CountdownRing(gameState: GameState())
}
