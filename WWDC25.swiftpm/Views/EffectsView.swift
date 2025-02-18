//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//
import SwiftUI

struct EffectsView: View {
    var color: Color = .green
    var body: some View {
        ZStack {
            // Fundo transparente
            Color.clear.edgesIgnoringSafeArea(.all)
            
            // Bordas com efeito de sombra colorida
            borderGlow()
        }
    }
    
    // Função que cria a borda colorida
    func borderGlow() -> some View {
        
        return RoundedRectangle(cornerRadius: 0)
            .stroke(color, lineWidth: 30) // Borda colorida
            .blur(radius: 20) // Suaviza a borda para efeito de sombra
            .edgesIgnoringSafeArea(.all)
            .opacity(0.6)

    }
}
#Preview {
    EffectsView()
}
