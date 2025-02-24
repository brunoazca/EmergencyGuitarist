//
//  CountDownRing.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//
import SwiftUI

struct CountdownRing: View {
    @ObservedObject var gameState: GameState
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

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
                            let endAngle: Angle = .degrees(Double(-90) + (360 * Double(gameState.progress)))

                            var path = Path()
                            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

                            context.stroke(path, with: .color(gameState.currentChordColor.opacity(gameState.shouldPlay ? 1 : 0.5)), lineWidth: isIPad ? 20 : 10)
                        }
                        if !gameState.shouldPlay {
                            Text("\(Int(ceil(gameState.progress * gameState.duration)))")
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
            if(gameState.isInShow){
                DispatchQueue.main.asyncAfter(deadline: .now()+4){
                    gameState.shouldPlay = false
                    gameState.progress = 1.0
                    gameState.duration = 3.75
                    gameState.soundPlayer.playSound("WWDC25Song")

                    gameState.startCountdown()
                }
            } else {
                gameState.shouldPlay = false
                gameState.progress = 1.0
                gameState.startCountdown()
            }
            
        }
        
    }


}

#Preview {
    CountdownRing(gameState: GameState())
}
