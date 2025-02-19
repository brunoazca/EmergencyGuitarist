//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 19/02/25.
//

import Foundation
import SwiftUI

class GameState: ObservableObject {
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
    
    @Published var inChordShape: Bool = false
    @Published var didPlayChord: Bool = false {didSet{
        previousTimer?.invalidate()
        if(didPlayChord) {
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
        print(effectIntensity)
    }}
    var previousTimer: Timer? = nil
    @Published var effectIntensity: CGFloat = 30
    @Published var playMetronome: Bool = false
    @Published var shouldPlay = false
}
