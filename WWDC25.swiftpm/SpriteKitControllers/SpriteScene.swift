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
    
    var metronomeNode: SKShapeNode {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: self.frame.height/8))
        node.fillColor = .gray
        node.strokeColor = .black
        return node
    }
    
    let metronomeField: SKNode = SKNode()
    
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
    
    func initMetronomeField(){
        for _ in 0..<10 {
            metronomeField.addChild(metronomeNode)
        }
        
        var xPosition = 0
        var childIndex = 0
        metronomeField.children.forEach{ child in
            child.position = CGPoint(x: xPosition, y: Int(-self.frame.height)/2 + 20)
            if (childIndex % 8 == 0){
                addChildChord(node: child)
            }
            childIndex += 1
            xPosition += 80
        }
        
        self.addChild(metronomeField)
        
        metronomeField.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.move(by: CGVector(dx: -80, dy: 0), duration: 0.5), SKAction.run{
            let newChild = self.metronomeNode
            self.metronomeField.addChild(newChild)
            newChild.position = CGPoint(x: xPosition, y: Int(-self.frame.height)/2 + 20)
            if (childIndex % 8 == 0){
                self.addChildChord(node: newChild)
            }
            xPosition += 80
            childIndex += 1
            }])))
    }
    
    func addChildChord(node: SKNode){
        let chordLabel = SKLabelNode(text: "A")
        chordLabel.fontSize = metronomeNode.frame.height
        chordLabel.position = CGPoint(x:node.frame.width/2, y: chordLabel.frame.height + node.frame.height/2)
        node.addChild(chordLabel)
//        AppLibrary.Instance.currentChordIndex += 1
    }
    
    override func sceneDidLoad() {
//        initMetronomeField()
    }
    
    override func update(_ currentTime: TimeInterval) {
        metronomeField.children.forEach{ child in
            let shapeChild = child as! SKShapeNode
            let childXWorldPos = metronomeField.position.x + child.position.x
            if (childXWorldPos > -40 && childXWorldPos < 70){
                shapeChild.fillColor = .white
                shapeChild.run(SKAction.scale(to: 1.5, duration: 0.2))
            } else if (childXWorldPos > -85 && childXWorldPos < 110){
                shapeChild.fillColor = UIColor(white: 0.7, alpha: 1)
                shapeChild.run(SKAction.scale(to: 1.2, duration: 0.2))
            } else {
                shapeChild.fillColor = .gray
                shapeChild.run(SKAction.scale(to: 1, duration: 0.1))
            }
            
            if (childXWorldPos < -self.frame.width/2) {
                child.removeFromParent()
            }
        }
    }
}

#Preview {
    GuitarView(appRouter: AppRouter())
}
