//
//  SpriteKitView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 12/02/25.
//

import Foundation
import SwiftUI
import SpriteKit

struct SpriteKitViewRepresentable: UIViewRepresentable {
    let scene: SpriteScene
    
    typealias UIViewControllerType = SKView
    
    init(size:CGSize, appRouter: AppRouter) {
        scene = SpriteScene(size: size, appRouter: appRouter)
        scene.size = size
        scene.scaleMode = .aspectFill
        scene.anchorPoint = .init(x:0.5, y:0.5)
    }
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true  // Garante transparência
        skView.backgroundColor = .clear   // Remove fundo do SKView
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.presentScene(scene)
    }
}
