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
    var soundPlayer = SoundPlayer()
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
    
    @Published var didPlayRightChord: Bool = false
    @Published var didPlayChord: Bool = false {
        didSet {
            previousTask?.cancel() // Cancela qualquer tarefa pendente

            if didPlayChord {
                if shouldPlay {
                    didPlayRightChord = true
                    increaseEffectIntensity()
                }
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
            } else {
                didPlayRightChord = false
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
    @Published var showArrow = false
    @Published var showCheck = false
    
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
            let thisCurrentMessage = currentMessage
            switch currentMessage.passMethod {
            case .aChord:
                currentChord = .A
                showChordIndicator = true
            case .cChord:
                showArrow = true
                shouldPlay = true
            case .eChord:
                showArrow = true
                shouldPlay = true
            case .playChord:
                showArrow = true
                shouldPlay = true
            case .positionGuitar:
                showCheck = true
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
                    showArrow = true

                    cancelTyping()

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
        showArrow = false
        challengeChordSequence = [.A, .C, .E, .E, .A, .C, .E, .E, .E]
        currentChordIndex = 0
        currentChord = .A
        isInShow = true
    }
    var typingCanceled = false

    func startTyping() {
        typedText = ""
        currentMessageIndex += 1
        currentIndex = 0
        showText = true
        endedTyping = false
        typingCanceled = false  // Inicializa o flag de cancelamento como false
        
        // Cria uma tarefa assíncrona para digitar o texto aos poucos
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            while let self = self, self.currentIndex < self.currentMessageText.count, !self.typingCanceled {
                DispatchQueue.main.async {
                    if self.currentIndex < self.currentMessageText.count {
                        self.typedText += String(self.currentMessageText[self.currentMessageText.index(self.currentMessageText.startIndex, offsetBy: self.currentIndex)])
                        self.currentIndex += 1
                    }
                }
                
                // Delay para simular a digitação
                usleep(40000) // 40ms de delay entre cada letra
            }
            
            // Usando Optional Chaining para verificar se self e endedTyping não são nulos
            DispatchQueue.main.async {
                self?.endedTyping = true
            }
        }
    }



    // Função para cancelar a digitação
    func cancelTyping() {
        typingCanceled = true
    }

    
    @Published var progress: CGFloat = 1
    @Published var progressAtualizer: Int = 10
    @Published var duration: TimeInterval = 3

    @Published var metronomeSpeed = (0.53*2)
    var countdownCanceled = false

    func startCountdown() {
        progress = 1.0
        runCountdown()
    }

    func runCountdown() {
        countdownCanceled = false
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            while progress > 0 && !countdownCanceled {
                DispatchQueue.main.async { [self] in
                    progress -= (metronomeSpeed/10)/duration

                    if progressAtualizer % 10 == 0 {
                        self.soundPlayer.playSound("Metronome")
                    }

                    progressAtualizer += 1

                    if progress <= 0 {
                        progress = 1
                        self.shouldPlay.toggle()

                        if self.shouldPlay {
                            if !isInShow {
                                self.duration = 2
                            } else {
                                self.duration = 1.25
                            }
                        } else {
                            currentChordIndex += 1
                            if currentChordIndex + 1 <= challengeChordSequence.count {
                                currentChord = challengeChordSequence[currentChordIndex]
                            } else {
                                countdownCanceled = true
                            }
                            self.duration = 3
                        }
                    }
                }

                // Usando um delay similar ao tempo do timer
                usleep(UInt32(metronomeSpeed / 10 * 1000000))
            }
        }
    }

    // Função para cancelar a contagem regressiva
    func cancelCountdown() {
        countdownCanceled = true
    }

    func reset() {
        isInShow = false
        currentChord = nil
        inChordShape = false
        didPlayChord = false
        effectIntensity = 30
        showMetronome = false
        showChordIndicator = false
        shouldPlay = true
        showArrow = false
        showCheck = false
        typedText = ""
        showText = true
        challengeChordSequence = [.A, .C, .E, .A, .C, .E]
        currentChordIndex = 0
        currentMessageIndex = -1
        currentChord = nil
        currentIndex = 0
        endedTyping = false
        
        previousTask?.cancel() // Cancela qualquer tarefa pendente
        previousTask = nil
        progressAtualizer = 10
        progress = 1
    }

}
