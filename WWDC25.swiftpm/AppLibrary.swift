//
//  AppLibrary.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 13/02/25.
//

import Foundation

class AppLibrary {
    static let Instance = AppLibrary()
    private init () {}
    
    let chordSequence: [SoundPlayer.Chord] = [.A,.C,.E,.A,.C,.E,.A,.C,.E]
    
    var currentIndex: Int = 0
    var currentChord: SoundPlayer.Chord?  {
        if (currentIndex <= chordSequence.count - 1) {
            return chordSequence[currentIndex]
        } else {
            return .A
        }
    }
}
