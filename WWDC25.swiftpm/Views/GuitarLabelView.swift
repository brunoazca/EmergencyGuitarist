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
    @ObservedObject var gameState: GameState
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var currentMessage: GuitarMessage {
        AppLibrary.Instance.messages[AppLibrary.Instance.currentMessageIndex]
    }
    
    var currentMessageText: String {
        currentMessage.text
    }
    
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
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, isIPad ? 120 : 50)
                            .padding()
                    }
                
            }
            .ignoresSafeArea()

        }
    }
    
    func startTyping() {
        typedText = ""
        currentIndex = 0
        
        // Cria um timer que vai "digitar" o texto aos poucos
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            if currentIndex < currentMessageText.count {
                typedText += String(currentMessageText[currentMessageText.index(currentMessageText.startIndex, offsetBy: currentIndex)])
                currentIndex += 1
            } else {
                switch currentMessage.passMethod {
                case .aChord:
                    gameState.currentChord = .A
                case .cChord:
                    gameState.currentChord = .C
                case .eChord:
                    gameState.currentChord = .E
                case .challenge:
                    gameState.currentChord = .A
                    default:
                        break
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                    switch currentMessage.passMethod {
                    case .time:
                        AppLibrary.Instance.currentMessageIndex += 1
                        startTyping()
                    case .challenge:
                        showText = false
                        gameState.playMetronome = true
                    case .positionGuitar:
                        break
                    default:
                        AppLibrary.Instance.currentMessageIndex += 1
                        startTyping()
                    }
                }
                timer?.invalidate()
            }
        }
    }
}


#Preview {
    GuitarLabelView(gameState: GameState())
}
