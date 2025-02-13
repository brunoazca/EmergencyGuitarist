//
//  SpriteViewController.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 12/02/25.
//

import Foundation
import SpriteKit
import SwiftUI

class SpriteScene: SKScene {
    @ObservedObject var appRouter: AppRouter
    
    var circleNode: SKShapeNode = {
        var node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 30, height: 30))
        return node
    }()
    
    init(size: CGSize, appRouter: AppRouter) {
        self.appRouter = appRouter
        super.init(size: size)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        view.allowsTransparency = true
        view.backgroundColor = .clear
    }
    
    override func sceneDidLoad() {
        addChild(circleNode)
    }
}
