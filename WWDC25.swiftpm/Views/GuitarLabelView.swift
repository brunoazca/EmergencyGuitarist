//
//  GuitarLabelView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//

import Foundation
import SwiftUI

struct GuitarLabelView: View {
    
    @ObservedObject var gameState: GameState
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        if(gameState.showText) {
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(0.6)) // Cor do retângulo
                    .frame(height: isIPad ? 200 : 100)
                    .shadow(color: .black, radius: 50, x: 0, y: 10) // Grande sombra

                    .overlay {
                        Text(gameState.typedText)
                            .foregroundStyle(.white)
                            .font(.system(size: isIPad ? 40 : 25))
                            .onAppear {
                                if(gameState.currentMessageIndex <= 0){
                                    gameState.startTyping()
                                }
                        
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, isIPad ? 120 : 50)
                            .padding()
                    }
                
            }
            .ignoresSafeArea()

        }
    }
    
    
}


#Preview {
    GuitarLabelView(gameState: GameState())
}
