//
//  SoundPlayer.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 28/01/25.
//

import Foundation
import AVFoundation

class SoundPlayer {
    var audioPlayer: AVAudioPlayer?
    
    enum Chord: String {
        case C = "C"
        case A = "A"
    }
    
    // Função para tocar o som
    func playChord(_ chord: Chord) {
        // Certifique-se de que o arquivo de som esteja no Bundle
        guard let soundURL = Bundle.main.url(forResource: String(describing: chord), withExtension: "mp3") else {
            print("Arquivo de áudio não encontrado.")
            return
        }
        
        do {
            // Tenta carregar o arquivo de áudio
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            
            // Inicia o áudio
            audioPlayer?.play()
            
        } catch {
            // Se houver um erro, o áudio não será carregado corretamente
            print("Erro ao tentar tocar o áudio: \(error.localizedDescription)")
        }
    }
}
