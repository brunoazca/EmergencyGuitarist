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
                Image(systemName: "arrowshape.down")
                    .resizable()
                    .opacity(0.5)
                    .frame(width: isIPad ? 200 : 100, height: isIPad ? 300 : 150)
                    .padding(.trailing, 100)
                    .padding(.top, isIPad ? 200 : 100)
            }
        }
    }
}

#Preview {
    RightArrow(gameState: GameState())
}
