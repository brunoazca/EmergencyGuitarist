//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 17/02/25.
//

import Foundation

struct GuitarMessage {
    let text: String
    let passMethod: MessagePassMethod
    
    enum MessagePassMethod{
        case time
        case positionGuitar
        case aChord
        case cChord
        case eChord
        case challenge
    }
}
