//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 24/02/25.
//

import Foundation
import SwiftUI


struct ConfirmButton: View {
    @ObservedObject var gameState: GameState
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    var body: some View {
        VStack{
            Spacer()
            HStack {
                Spacer()
                Button{
                    gameState.startTyping()
                    gameState.showCheck = false
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: isIPad ? 80 : 40, height: isIPad ? 80 : 40)
                }.padding()
                    .padding(.bottom, isIPad ? 200 : 100)
            }
            
        }
        
    }
}
#Preview {
    ConfirmButton(gameState: GameState())
}
