//
//  SoundPlayer.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 28/01/25.
//
import Foundation
import AVFoundation

class SoundPlayer {
    var audioPlayers: [String: AVAudioPlayer] = [:] // Armazena múltiplos players
    
    enum Chord: String {
        case C = "C"
        case A = "A"
        case D = "D"
        case E = "E"
    }
    
    // Função para tocar acordes (chords) simultaneamente
    func playChord(_ chord: Chord) {
        playSound(chord.rawValue)
    }
    
    // Função para tocar qualquer som simultaneamente
    func playSound(_ name: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "m4a") else {
            print("Arquivo de áudio \(name) não encontrado.")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.prepareToPlay()
            player.play()
            
            // Armazena o player no dicionário para evitar ser liberado pela memória
            audioPlayers[name] = player
            
        } catch {
            print("Erro ao tentar tocar o áudio \(name): \(error.localizedDescription)")
        }
    }
}
