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
    
    
    let messages: [GuitarMessage] = [
        GuitarMessage(text: "Place the iPad in front of you and step back a little so your upper body and head fit within the camera frame.", passMethod: .time),
        GuitarMessage(text:  "Great! To play the guitar, you need to use both hands!", passMethod: .time),
        GuitarMessage(text: "With the left hand, you press the strings to define the note that will be played when you strum the strings with your right hand!", passMethod: .time),
        GuitarMessage(text: "Depending on your left hand fingers' position, you can create different chords to form songs!", passMethod: .time),
        GuitarMessage(text: "Let's start with the A chord! Place your index, middle and ring fingers in the indicated positions on the guitar neck!", passMethod: .aChord),
        GuitarMessage(text: "Now, with your fingers in place, strum the guitar with your right hand!", passMethod: .playChord),
        GuitarMessage(text: "That's it! Now let's try another chord: this one is E.", passMethod: .eChord),
        GuitarMessage(text: "And now for the last one: C", passMethod: .cChord),
        GuitarMessage(text: "Ok, now let's add some rhythm! When the counter gets to 0, play the chord indicated on the guitar!", passMethod: .challenge),
        GuitarMessage(text: "WOOOOOW, you did it!! You're more than ready to the show! Let's go!", passMethod: .show)
    ]
}
