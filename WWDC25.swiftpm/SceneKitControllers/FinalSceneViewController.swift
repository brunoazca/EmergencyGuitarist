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

class FinalSceneViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    @ObservedObject var appRouter: AppRouter
    @ObservedObject var gameState: GameState
    
    var typedText = ""
    let messages: [String] = ["Oh, WHAT A SHOW!!! We did it! I'm so proud of you!", "I hope you enjoyed this experience and feel motivated to learn more about music and guitar! See you at the next SHOW!"]
    var messageIndex = 0
    var currentIndex = 0 // Índice da letra atual
    var getPlayButton = false
    var playButtonStartPos: SCNVector3
    var playButtonStartOrientation: SCNVector4
    var canPlayButton = false
    var startCamera: SCNNode
    var cameraStartPos: SCNVector3
    var introCamera: SCNNode
    
    let scene = SCNScene(named: "IntroScene.scn")!
    var leftEyebrow: SCNNode
    var rightEyebrow: SCNNode
    var ponteBase: SCNNode
    var ponteFrente: SCNNode
    var textNode: SCNText
    var textBubble: SCNNode
    var textBubbleArrow: SCNNode
    var titleNode: SCNNode
    var publicNode: SCNNode
    var publicSpotLightsNode: SCNNode
    var playButtonNode: SCNNode
    var floor: SCNNode
    var finalGuitarConteiner: SCNNode
    var cameraInterface: SCNNode
    
    let scnView:SCNView
    
    init(size: CGSize, appRouter: AppRouter, gameState: GameState) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        
        startCamera = scene.rootNode.childNode(withName: "startCamera", recursively: true)!
        introCamera = scene.rootNode.childNode(withName: "introCamera", recursively: true)!
        cameraInterface = scene.rootNode.childNode(withName: "CameraInterface", recursively: true)!
        
        textNode = scene.rootNode.childNode(withName: "FinalTextNode", recursively: true)!.geometry as! SCNText
        textBubble = scene.rootNode.childNode(withName: "FinalTextBubble", recursively: true)!
        textBubbleArrow = scene.rootNode.childNode(withName: "FinalTextBubbleArrow", recursively: true)!
        titleNode = scene.rootNode.childNode(withName: "title", recursively: true)!
        
        finalGuitarConteiner = scene.rootNode.childNode(withName: "FinalGuitarConteiner", recursively: true)!

        leftEyebrow = finalGuitarConteiner.childNode(withName: "EyebrowL", recursively: true)!
        rightEyebrow = finalGuitarConteiner.childNode(withName: "EyebrowR", recursively: true)!
        ponteBase = finalGuitarConteiner.childNode(withName: "Plane_005", recursively: true)!
        ponteFrente = finalGuitarConteiner.childNode(withName: "Plane_001", recursively: true)!
        playButtonNode = scene.rootNode.childNode(withName: "PlayButton", recursively: true)!
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        publicNode = scene.rootNode.childNode(withName: "Public", recursively: true)!
        publicSpotLightsNode = scene.rootNode.childNode(withName: "PublicSpotLights", recursively: true)!
        
        textNode.string = ""
        textNode.font = UIFont(name: "HelveticaNeue", size: 6)!
        
        textNode.containerFrame = CGRect(x: -5, y: -50, width: 85, height: 60) // Define um limite
        
        textNode.isWrapped = true
        textBubble.isHidden = true
        textBubbleArrow.isHidden = true
        
        finalGuitarConteiner.isHidden = false
        titleNode.isHidden = true
        cameraStartPos = startCamera.position
        
        playButtonStartPos = playButtonNode.worldPosition
        playButtonStartOrientation = playButtonNode.worldOrientation
        
        self.appRouter = appRouter
        self.gameState = gameState
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
        scnView.delegate = self
        scnView.pointOfView = startCamera
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animatePeople()
        animateSpotLights()
        getPlayButton = true
        
        playButtonNode.physicsBody?.collisionBitMask = floor.physicsBody!.categoryBitMask | 1
        playButtonNode.physicsBody?.isAffectedByGravity = true
        playButtonNode.worldPosition = publicNode.worldPosition + SCNVector3(-30, 10, 15)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            startTyping()
            speakAnimation()
            textBubble.isHidden = false
            textBubbleArrow.isHidden = false
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if (getPlayButton) {
            publicNode.childNodes.forEach{ child in
                if(child.presentation.worldPosition.distance(to: playButtonNode.presentation.worldPosition) <= 15) {
                    var vector =                     playButtonNode.presentation.worldPosition - child.presentation.worldPosition
                    vector.y = 0
                    child.removeAction(forKey: "Jump")
                    child.physicsBody?.applyForce(vector*(1/50), asImpulse: true)
                }
            }
        }
    }
    
    func animateSpotLights(){
        publicSpotLightsNode.childNodes.forEach { child in
            child.runAction(generateSpotLightAction())
        }
    }
    
    func generateSpotLightAction() -> SCNAction{
        let invertDirection = Bool.random()
        let randomX = CGFloat.random(in: -1...1)
        
        return SCNAction.repeatForever(SCNAction.sequence([SCNAction.rotateBy(x: randomX, y: 0, z: 0.7 * (invertDirection ? -1 : 1), duration: 3), SCNAction.rotateBy(x: -randomX, y: 0, z: -0.7 * (invertDirection ? -1 : 1), duration: 3), SCNAction.wait(duration: 1)]))
    }
    
    func animatePeople(){
        publicNode.childNodes.forEach { child in
            child.runAction(generatePersonAction(), forKey: "Jump")
            child.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            child.physicsBody?.isAffectedByGravity = true
            child.physicsBody?.categoryBitMask = 1
            child.physicsBody?.collisionBitMask = floor.physicsBody!.categoryBitMask |  child.physicsBody!.categoryBitMask
        }
    }
    
    func generatePersonAction() -> SCNAction{
        let randomTime = TimeInterval.random(in: 1...3)
        return SCNAction.repeatForever(SCNAction.sequence([SCNAction.wait(duration: randomTime), SCNAction.run({node in
            node.physicsBody?.applyForce(SCNVector3(x: 0, y: Float.random(in: 0.7...2.2), z: 0), asImpulse: true)
        })]))
    }
    
    func startTyping() {
        typedText = ""
        currentIndex = 0
        
        // Função recursiva para simular o comportamento do timer
        func typeNextCharacter() {
            // Verifica se ainda há caracteres para adicionar
            if currentIndex < messages[messageIndex].count {
                // Adiciona o próximo caractere
                typedText += String(messages[messageIndex][messages[messageIndex].index(messages[messageIndex].startIndex, offsetBy: currentIndex)])
                currentIndex += 1
                textNode.string = typedText
                
                // Chama o próximo caractere após o intervalo de tempo
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    typeNextCharacter()
                }
            } else {
                // Se a digitação estiver completa, inicia o próximo processo após o atraso de 4 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [self] in
                    if messageIndex + 1 == messages.count {
                        canPlayButton = true
                        playButtonNode.physicsBody?.isAffectedByGravity = false
                        playButtonNode.worldPosition = playButtonStartPos
                        playButtonNode.worldOrientation  = playButtonStartOrientation
                        playButtonNode.physicsBody?.velocity = SCNVector3Zero
                        playButtonNode.physicsBody?.angularVelocity = SCNVector4Zero
                        let textNode = playButtonNode.childNode(withName: "playText", recursively: true)!
                        textNode.position.z -= 0.23
                        let text = textNode.geometry as! SCNText
                        text.string = "REPLAY"
                        
                    } else {
                        messageIndex += 1
                        typedText = ""
                        startTyping()
                        speakAnimation()
                    }
                }
            }
        }
        
        // Inicia a digitação
        typeNextCharacter()
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: scnView) else {return}
        
        if(canPlayButton){
            if location.y <= scnView.frame.maxY*2/3 &&
                location.y >= scnView.frame.maxY/2 && location.x >= scnView.frame.width/2 - 90 && location.x <= scnView.frame.width/2 + 90{
                playButtonNode.physicsBody?.applyForce(SCNVector3(3, 1.4, 0), asImpulse: true)
                playButtonNode.physicsBody?.collisionBitMask = floor.physicsBody!.categoryBitMask | 1
                playButtonNode.physicsBody?.isAffectedByGravity = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    gameState.reset()
                    appRouter.router = .introScene
                }
                
            }
        }
    }
}
#Preview {
    FinalView(appRouter: AppRouter(), gameState: GameState())
}
