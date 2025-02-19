//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//

import Foundation

import UIKit
import QuartzCore
import SceneKit
import SwiftUI

class IntroSceneViewController: UIViewController, SCNPhysicsContactDelegate {
    @ObservedObject var appRouter: AppRouter
    var typedText = ""
    let messages: [String] = ["Hey! I can't believe you are here! The guitarrist that would play in the show couldn't arrive...", "Could you play with me in the show? I can teach you the basics! Oh, and my name is Violo!"]
    var messageIndex = 0
    var currentIndex = 0 // Índice da letra atual
    var timer: Timer? // Timer para controlar a
    
    let scene = SCNScene(named: "IntroScene.scn")!
    var leftEyebrow: SCNNode
    var rightEyebrow: SCNNode
    var ponteBase: SCNNode
    var ponteFrente: SCNNode
    var textNode: SCNText
    var textBubble: SCNNode

    
    let scnView:SCNView
    
    init(size: CGSize, appRouter: AppRouter) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        textNode = scene.rootNode.childNode(withName: "TextNode", recursively: true)!.geometry as! SCNText
        textBubble = scene.rootNode.childNode(withName: "TextBubble", recursively: true)!

        leftEyebrow = scene.rootNode.childNode(withName: "EyebrowL", recursively: true)!
        rightEyebrow = scene.rootNode.childNode(withName: "EyebrowR", recursively: true)!
        ponteBase = scene.rootNode.childNode(withName: "Plane_005", recursively: true)!
        ponteFrente = scene.rootNode.childNode(withName: "Plane_001", recursively: true)!

        textNode.font = UIFont(name: "HelveticaNeue", size: 6)!
        
        textNode.containerFrame = CGRect(x: -5, y: -50, width: 85, height: 60) // Define um limite
        
        textNode.isWrapped = true

        self.appRouter = appRouter
        super.init(nibName: nil, bundle: nil)
        self.view = self.scnView
        
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        //        scnView.debugOptions = [.showPhysicsShapes]
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // set the scene to the view
        scnView.scene = scene
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startTyping()
        speakAnimation()
    }
    
    func startTyping() {
        typedText = ""
        currentIndex = 0
        
        // Cria um timer que vai "digitar" o texto aos poucos
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [self] _ in
            if currentIndex < messages[messageIndex].count {
                typedText += String(messages[messageIndex][messages[messageIndex].index(messages[messageIndex].startIndex, offsetBy: currentIndex)])
                currentIndex += 1
                textNode.string = typedText
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4){ [self] in
                    if (messageIndex + 1 == messages.count) {
                        appRouter.router = .arView
                    } else{
                        messageIndex += 1
                        typedText = ""
                        startTyping()
                        speakAnimation()
                    }
                }
                timer?.invalidate()
            }
        }
    }
    
    func speakAnimation(){
        rightEyebrow.runAction(eyeBrowAnimation(isRight: true))
        leftEyebrow.runAction(eyeBrowAnimation(isRight: false))
        
        let actionPonte = SCNAction.repeat(SCNAction.sequence([SCNAction.move(by: SCNVector3(0, 0.015, 0), duration: 1), SCNAction.move(by: SCNVector3(0, -0.015, 0), duration: 1)]), count: 4)
        ponteBase.runAction(actionPonte)
        ponteFrente.runAction(actionPonte)
    }
    
    func eyeBrowAnimation(isRight: Bool)->SCNAction {
        let xOffset: Float = isRight ? 0.5 : -0.5
        let yOffset: Float = 0.4
        let zRotation: CGFloat = -0.5
        
        return SCNAction.repeat( (SCNAction.sequence([SCNAction.group([SCNAction.move(by: SCNVector3(x: xOffset, y: yOffset, z: 0), duration: 0.5), SCNAction.rotateBy(x: 0, y: 0, z: zRotation, duration: 0.5)]), SCNAction.group([SCNAction.move(by: SCNVector3(x: -xOffset, y: -yOffset, z: 0), duration: 0.5), SCNAction.rotateBy(x: 0, y: 0, z: -zRotation, duration: 0.5)])])), count: 8)
    }
}
#Preview {
    IntroView(appRouter: AppRouter())
}
