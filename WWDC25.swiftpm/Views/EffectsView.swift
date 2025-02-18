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
        RoundedRectangle(cornerRadius: 0)
            .stroke(color, lineWidth: 30) // Borda colorida
            .blur(radius: 20) // Suaviza a borda para efeito de sombra
            .edgesIgnoringSafeArea(.all)
            .opacity(0.6)
            .allowsHitTesting(false)
    }
}
#Preview {
    EffectsView()
}
