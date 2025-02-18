//
//  GuitarLabelView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//

import Foundation
import SwiftUI

struct GuitarLabelView: View {
    @State private var typedText = "" // Texto que será mostrado com o efeito de digitação
    @State var showText = true
    @State private var currentIndex = 0 // Índice da letra atual
    @State private var timer: Timer? // Timer para controlar a digitação
    @Binding var startMetronome: Bool
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    let fullText = "Oh! I'm so glad you arrived! My name is Violo. Can you beat my challenge??"

    var body: some View {
        if(showText) {
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(0.6)) // Cor do retângulo
                    .frame(height: isIPad ? 200 : 100)
                    .shadow(color: .black, radius: 50, x: 0, y: 10) // Grande sombra
                    .overlay {
                        Text(typedText)
                            .foregroundStyle(.white)
                            .font(.system(size: isIPad ? 40 : 25))
                            .onAppear {
                                startTyping()
                            }
                    }
            }
            .ignoresSafeArea()
        }
    }
    
    func startTyping() {
        typedText = ""
        currentIndex = 0
        
        // Cria um timer que vai "digitar" o texto aos poucos
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if currentIndex < fullText.count {
                typedText += String(fullText[fullText.index(fullText.startIndex, offsetBy: currentIndex)])
                currentIndex += 1
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    showText = false
                    startMetronome = true
                }
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    GuitarLabelView(startMetronome: .constant(false))
}
