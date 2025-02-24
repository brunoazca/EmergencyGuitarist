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
    @ObservedObject var gameState: GameState
    @State var metronomeTimer: Timer? = nil
    @State var metronomeSpeed = (0.53*2)
    @State var progressAtualizer = 10

    
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
            metronomeTimer?.invalidate()
            if(gameState.isInShow){
                DispatchQueue.main.asyncAfter(deadline: .now()+4){
                    gameState.shouldPlay = false
                    progress = 1.0
                    duration = 3.75
                    soundPlayer.playSound("WWDC25Song")
                    startCountdown()
                }
            } else {
                gameState.shouldPlay = false
                progress = 1.0
                startCountdown()
            }
            
        }
    }

    func startCountdown() {
        progress = 1.0
        runCountdown()
    }

    func runCountdown() {
       
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: metronomeSpeed/10, repeats: true) { timer in
            progress -= (metronomeSpeed/10)/duration
            
            if(progressAtualizer % 10 == 0){
                self.soundPlayer.playSound("Metronome")
            }
            progressAtualizer += 1

            if(progress <= 0) {
                progress = 1
                self.gameState.shouldPlay.toggle()
                if self.gameState.shouldPlay {
                    if(!gameState.isInShow){
                        self.duration = 2
                    } else {
                        self.duration = 1.25
                    }
                } else {
                    gameState.currentChordIndex += 1
                    if gameState.currentChordIndex + 1 <= gameState.challengeChordSequence.count{
                        gameState.currentChord = gameState.challengeChordSequence[gameState.currentChordIndex]
                    } else {
                        timer.invalidate()
                        metronomeTimer?.invalidate()
                    }
                    self.duration = 3
                }
            }
        }
       

    }

}

#Preview {
    CountdownRing(gameState: GameState())
}
