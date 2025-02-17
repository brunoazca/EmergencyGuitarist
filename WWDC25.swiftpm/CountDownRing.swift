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

    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var soundPlayer =  SoundPlayer()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .opacity(0.6)
                .shadow(color: .black, radius: 30, x: 0, y: 0) // Grande sombra
                .frame(width: isIPad ? 220 : 110, height: isIPad ? 220 : 110)
                .overlay{
                    ZStack{
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
                            Text(((progress * duration) + 1).description.prefix(1))
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
        progress = 1
        let step = 0.01 // Pequeno decremento a cada atualização
        let interval = duration * step // Tempo de cada atualização
        var accumulatedInterval: CGFloat = 0
        
        // Inicia o Timer de Metronome apenas uma vez
        soundPlayer.playSound("Metronome")
        

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            accumulatedInterval += interval
            if (accumulatedInterval >= 1 && !isPlay){
                accumulatedInterval = 0
                soundPlayer.playSound("Metronome")
            }
            if progress > 0 {
                progress -= step
            } else {
                isPlay.toggle()
                if isPlay {
                    duration = 2
                    color = .green
                } else {
                    AppLibrary.Instance.currentIndex += 1
                    duration = 3
                    color = .blue
                }
                startCountdown()

                timer.invalidate()
            }
        }
    }
}

#Preview{
    CountdownRing()
}
