//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//
import SwiftUI

struct EffectsView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .stroke(gameState.currentChordColor, lineWidth: gameState.effectIntensity) // Borda colorida
            .blur(radius: 20) // Suaviza a borda para efeito de sombra
            .edgesIgnoringSafeArea(.all)
            .opacity(gameState.shouldPlay ? 0.6 : 0.4)
            .allowsHitTesting(false)
    }
}
#Preview {
    EffectsView(gameState: GameState())
}
