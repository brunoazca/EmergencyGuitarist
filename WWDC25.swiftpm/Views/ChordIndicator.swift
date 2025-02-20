//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 19/02/25.
//

import Foundation
import SwiftUI

struct ChordIndicator: View {
    @ObservedObject var gameState: GameState

    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }


    var body: some View {
        if let chord = gameState.currentChord{
            ZStack {
                RoundedRectangle(cornerRadius: 25.0)
                    .opacity(0.6)
                    .foregroundStyle(.black)
                    .shadow(color: .black, radius: 30, x: 0, y: 0)
                    .frame(width: isIPad ? 180 : 110, height: isIPad ? 180 : 110)
                    .overlay {
                            VStack {
                                Text("\(chord.rawValue)")
                                    .font(.system(size: isIPad ? 120 : 60, weight: .semibold, design: .default))
                                .foregroundColor(gameState.currentChordColor)
                                Text("Current Chord")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                
                        }
                    }
                    .padding()
                }
        }
        
    }
}


#Preview {
    ChordIndicator(gameState: GameState())
}
