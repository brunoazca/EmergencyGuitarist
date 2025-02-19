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
    var currentChordIndex: Int = 0
    
    var currentMessageIndex = 0
    let messages: [GuitarMessage] = [
        GuitarMessage(text: "Place the iPad in front of you and step back a little so your upper body and head fit within the camera frame.", passMethod: .challenge),
        GuitarMessage(text: "Great! Now we are together! Hope I can count on you, hahaha", passMethod: .time),
        GuitarMessage(text:  "To play the guitar, you need to use both hands!", passMethod: .time),
        GuitarMessage(text: "With your left hand, you press the strings to define the note that will be played, depending on your fingers' place.", passMethod: .time),
        GuitarMessage(text: "With your right hand, you strum the strings to produce the notes they represent!", passMethod: .time),
        GuitarMessage(text: "By combining the finger positions of your left hand with the strumming of your right hand, you can create chords that form songs!", passMethod: .time),
        GuitarMessage(text: "Let's start with the A chord! First, place your index finger (blue), middle finger (orange), and ring finger (purple) in the indicated positions on the guitar neck!", passMethod: .aChord),
        GuitarMessage(text: "Now, with your fingers in place, strum the guitar with your right hand!", passMethod: .aChord),
        GuitarMessage(text: "That's it! Now let's try another chord: this one is E.", passMethod: .eChord),
        GuitarMessage(text: "And now for the last one: C", passMethod: .cChord),
        GuitarMessage(text: "Ok, now let's add some rhythm! When the counter gets to 0, play the chord indicated on the guitar!", passMethod: .challenge),
    ]
}
