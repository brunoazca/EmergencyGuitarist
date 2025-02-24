//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 23/02/25.
//

import Foundation
import SwiftUI

struct RightArrow: View{
    @ObservedObject var gameState: GameState
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View{
        VStack{
            HStack{
                Spacer()
                Image(systemName: gameState.didPlayChord ? "arrowshape.down.fill" : "arrowshape.down")
                    .resizable()
                    .opacity(gameState.didPlayRightChord ? 0.8 : gameState.shouldPlay ? 0.8 : 0.5)
                    .frame(width: isIPad ? 200 : 100, height: isIPad ? 300 : 150)
                    .padding(.trailing, 100)
                    .padding(.top, isIPad ? 200 : 100)
                    .shadow(radius: 10)
                    .foregroundStyle(gameState.didPlayRightChord ? .green : gameState.shouldPlay ? .green : .black)

            }
        }
    }
}

#Preview {
    RightArrow(gameState: GameState())
}
