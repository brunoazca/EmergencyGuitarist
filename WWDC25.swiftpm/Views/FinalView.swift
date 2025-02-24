//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 23/02/25.
//

import Foundation
import SwiftUI

struct FinalView: View {
    @ObservedObject var appRouter: AppRouter
    @ObservedObject var gameState: GameState

    var body: some View {
        GeometryReader{ geo in
            FinalSceneViewControllerRepresentable(size: geo.size, appRouter: appRouter, gameState: gameState)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FinalView(appRouter: AppRouter(), gameState: GameState())
}
