//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 19/02/25.
//

import Foundation
import SwiftUI

class GameState: ObservableObject {
    @Published var currentChord: SoundPlayer.Chord? = nil {didSet{
        print(currentChord)
    }}
    var currentChordColor: Color {
        switch currentChord {
        case .A:
            return .pink
        case .C:
            return .yellow
        case .E:
            return .green
        case .D:
            return .blue
        case nil:
            return .clear
        }
    }
    
    @Published var inChordShape: Bool = false {didSet{
        if (inChordShape && currentMessage.passMethod == .aChord){
            startTyping()
        }
    }}
    
    @Published var didPlayChord: Bool = false {didSet{
        previousTimer?.invalidate()
        if(didPlayChord) {
            if(currentMessage.passMethod == .playChord || currentMessage.passMethod == .eChord || currentMessage.passMethod == .cChord){
                startTyping()
            }
            if(shouldPlay){
                previousTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
                    if (effectIntensity <= 50){
                        effectIntensity += 8
                    } else {
                        timer.invalidate()
                    }
                }
            }
        } else {
            previousTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
                if (effectIntensity >= 30){
                    effectIntensity -= 8
                } else {
                    timer.invalidate()
                }
            }
        }
    }}
    var previousTimer: Timer? = nil
    @Published var effectIntensity: CGFloat = 30
    
    @Published var showMetronome: Bool = false
    @Published var showChordIndicator: Bool = false
    @Published var shouldPlay = true
    
    @Published var typedText = ""
    @Published var showText = true
    
    let chordSequence: [SoundPlayer.Chord] = [.A,.C,.E,.A,.C,.E]
    @Published var currentChordIndex: Int = 0 { didSet{
        print(currentChordIndex)
        if(currentChordIndex + 1 == chordSequence.count + 1){
            startTyping()
        }
    }}
    
    var currentMessageIndex = -1
    private var currentIndex = 0 // Índice da letra atual
    private var timer: Timer? // Timer para controlar a digitação
    var currentMessage: GuitarMessage {
        if (currentMessageIndex != -1 && currentMessageIndex - 1 <= AppLibrary.Instance.messages.count){
            return AppLibrary.Instance.messages[currentMessageIndex]
        } else {
            return AppLibrary.Instance.messages[0]
        }
    }
    var currentMessageText: String {
        currentMessage.text
    }
    
    func startTyping() {
        typedText = ""
        currentMessageIndex += 1
        currentIndex = 0
        showText = true

        // Cria um timer que vai "digitar" o texto aos poucos
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [self] _ in
            if currentIndex < currentMessageText.count {
                typedText += String(currentMessageText[currentMessageText.index(currentMessageText.startIndex, offsetBy: currentIndex)])
                currentIndex += 1

            } else {
                let thisCurrentMessage = currentMessage
                switch currentMessage.passMethod {
                case .aChord:
                    currentChord = .A
                    showChordIndicator = true
                case .cChord:
                    currentChord = .C
                case .eChord:
                    currentChord = .E
                default:
                    break
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 4){ [self] in

                    switch thisCurrentMessage.passMethod {
                    case .time:
                        startTyping()
                    case .challenge:
                        showText = false
                        currentChord = .A
                        showChordIndicator = true
                        showMetronome = true
                    case .positionGuitar:
                        break
                    default:
                        break
                    }
                }
                timer!.invalidate()
                timer = nil
            }
        }
    }
}
