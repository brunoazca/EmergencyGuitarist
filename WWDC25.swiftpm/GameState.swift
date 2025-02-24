//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 19/02/25.
//

import Foundation
import SwiftUI

class GameState: ObservableObject {
    @ObservedObject var appRouter: AppRouter = AppRouter()
    
    var isInShow = false
    @Published var currentChord: SoundPlayer.Chord? = nil
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
    var currentChordColorForAR: UIColor {
        switch currentChord {
        case .A:
            return UIColor(cgColor: CGColor(red: 0.5, green: 0, blue: 0, alpha: 1))
        case .C:
            return UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0, alpha: 1))
        case .E:
            return  UIColor(cgColor: CGColor(red: 0, green: 0.5 ,blue: 0, alpha: 1))
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
    
    @Published var didPlayChord: Bool = false {
        didSet {
            previousTask?.cancel() // Cancela qualquer tarefa pendente

            if didPlayChord {
                if currentMessage.passMethod == .playChord ||
                   currentMessage.passMethod == .eChord ||
                    currentMessage.passMethod == .cChord && shouldPlay {
                    shouldPlay = false
                    startTyping()
                    switch currentMessage.passMethod {
                    case .cChord:
                        currentChord = .C
                    case .eChord:
                        currentChord = .E
                    default:
                        break
                    }
                }
                if shouldPlay {
                    increaseEffectIntensity()
                }
            } else {
                decreaseEffectIntensity()
            }
        }
    }

    var previousTask: Task<Void, Never>? = nil
    var effectIntensity: CGFloat = 30

    private func increaseEffectIntensity() {
        previousTask = Task {
            while effectIntensity <= 50 {
                effectIntensity += 8
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }
        }
    }

    private func decreaseEffectIntensity() {
        previousTask = Task {
            while effectIntensity >= 30 {
                effectIntensity -= 8
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }
        }
    }
    
    @Published var showMetronome: Bool = false
    @Published var showChordIndicator: Bool = false
    @Published var shouldPlay = true
    
    @Published var typedText = ""
    @Published var showText = true
    
    var challengeChordSequence: [SoundPlayer.Chord] = [.A,.C,.E,.A,.C,.E]
    
    @Published var currentChordIndex: Int = 0 { didSet{
        if(currentChordIndex + 1 == challengeChordSequence.count + 1){
            if(!isInShow){
                startTyping()
                showMetronome = false
                showChordIndicator = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){ [self] in
                    appRouter.router = .finalScene
                    showMetronome = false
                    showChordIndicator = false
                }
            }
            
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
    var endedTyping = false {didSet{
        if(endedTyping){
            if let timer{
                timer.invalidate()
            }
            let thisCurrentMessage = currentMessage
            switch currentMessage.passMethod {
            case .aChord:
                currentChord = .A
                showChordIndicator = true
                shouldPlay = true
            case .cChord:
                shouldPlay = true
            case .eChord:
                shouldPlay = true
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
                    if let timer{
                        timer.invalidate()
                    }

                case .positionGuitar:
                    break
                case .show:
                    startShow()
                default:
                    break
                }
            }
        }
    }}
    
    func startShow(){
        appRouter.router = .showIntro
        showText = false
        showChordIndicator = false
        showMetronome = false
        challengeChordSequence = [.A, .C, .E, .E, .A, .C, .E, .E, .E]
        currentChordIndex = 0
        currentChord = .A
        isInShow = true
    }
    
    func startTyping() {
        typedText = ""
        currentMessageIndex += 1
        currentIndex = 0
        showText = true
        endedTyping = false

        // Cria um timer que vai "digitar" o texto aos poucos
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [self] _ in
            if currentIndex < currentMessageText.count {
                typedText += String(currentMessageText[currentMessageText.index(currentMessageText.startIndex, offsetBy: currentIndex)])
                currentIndex += 1

            } else {
                if(!endedTyping){
                    endedTyping = true
                }
            }
        }
    }
}
