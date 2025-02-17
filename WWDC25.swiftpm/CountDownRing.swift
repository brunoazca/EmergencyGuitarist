//
//  CountDownRing.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//

import SwiftUI

struct CountdownRing: View {
    @State var progress: CGFloat = 1.0 // Começa cheio
    @State var duration: TimeInterval = 3 // Duração da animação
    @State var isPlay = false
    @State var color = Color.blue
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var soundPlayer =  SoundPlayer()

    var body: some View {
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
            .frame(width: isIPad ? 200 : 100, height: isIPad ? 200 : 100)
            
            if(!isPlay) {
                Text(((progress * duration) + 1).description.prefix(1))
                    .font(.system(size: isIPad ? 50 : 25))
                    .fontWeight(.bold)
            } else {
                Text("PLAY!")
                    .font(.system(size: isIPad ? 50 : 25))
                    .fontWeight(.bold)
            }
            
        }
        .shadow(radius: 10)
        .onAppear {
            startCountdown()
        }
    }

    func startCountdown() {
        progress = 1
        let step = 0.01 // Pequeno decremento a cada atualização
        let interval = duration * step // Tempo de cada atualização
        var metronomeTimer = Timer()
        
        if(!isPlay){
            soundPlayer.playSound("Metronome")
            metronomeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                soundPlayer.playSound("Metronome")
            }
        }
        

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if progress > 0 {
                progress -= step
            } else {
                isPlay.toggle()
                if(isPlay){
                    duration = 1
                    color = .green
                    startCountdown()
                } else {
                    AppLibrary.Instance.currentIndex += 1
                    duration = 3
                    color = .blue
                    startCountdown()
                }
                metronomeTimer.invalidate()
                timer.invalidate() // Para o timer quando chegar a 0
            }
        }
    }
}

#Preview{
    CountdownRing()
}
