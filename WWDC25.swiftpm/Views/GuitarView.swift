//
//  SceneView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//

import Foundation
import SwiftUI
import SpriteKit

var arview: ARSceneViewControllerRepresentable? = nil

struct GuitarView: View{
    @ObservedObject var appRouter: AppRouter
    @State var startMetronome = false
    @ObservedObject var gameState: GameState
    
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                makeARScene(size: geo.size, appRouter: appRouter, gameState: gameState)
//                SpriteKitViewRepresentable(size: geo.size, appRouter: appRouter)
//                       .frame(width: geo.size.width, height: geo.size.height)
//                       .background(Color.clear)
//                       .allowsHitTesting(true)
                
            }.ignoresSafeArea()

            EffectsView(gameState: gameState)
            
            
            VStack{
                HStack{
                    if(gameState.showMetronome){
                        CountdownRing(gameState: gameState)
                    }
                    if(gameState.showChordIndicator){
                        ChordIndicator(gameState: gameState)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }.animation(.default)
            
            
            GuitarLabelView(gameState: gameState)
        }.onAppear{
            gameState.appRouter = appRouter
        }
    }
    func makeARScene(size: CGSize, appRouter: AppRouter, gameState: GameState)->ARSceneViewControllerRepresentable{
        let arViewRep = arview ?? ARSceneViewControllerRepresentable(size: size, appRouter: appRouter, gameState: gameState)
        arview = arViewRep
        return arview!
    }
}

#Preview {
    GuitarView(appRouter: AppRouter(), gameState: GameState())
}
    

