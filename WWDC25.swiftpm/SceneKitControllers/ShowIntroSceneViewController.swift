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

class ShowIntroSceneViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {
    @ObservedObject var appRouter: AppRouter
    @ObservedObject var gameState: GameState
    
    var startCamera: SCNNode
    var cameraStartPos: SCNVector3
    var introCamera: SCNNode
    
    let scene = SCNScene(named: "IntroScene.scn")!
    var publicNode: SCNNode
    var publicSpotLightsNode: SCNNode
    var titleNode: SCNNode
    var playButtonNode: SCNNode

    var floor: SCNNode
    var cameraInterface: SCNNode

    let scnView:SCNView
    
    init(size: CGSize, appRouter: AppRouter, gameState: GameState) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        
        startCamera = scene.rootNode.childNode(withName: "startCamera", recursively: true)!
        introCamera = scene.rootNode.childNode(withName: "introCamera", recursively: true)!
        cameraInterface = scene.rootNode.childNode(withName: "CameraInterface", recursively: true)!
        playButtonNode = scene.rootNode.childNode(withName: "PlayButton", recursively: true)!

        titleNode = scene.rootNode.childNode(withName: "title", recursively: true)!
        
        floor = scene.rootNode.childNode(withName: "floor", recursively: true)!
        publicNode = scene.rootNode.childNode(withName: "Public", recursively: true)!
        publicSpotLightsNode = scene.rootNode.childNode(withName: "PublicSpotLights", recursively: true)!

        cameraStartPos = startCamera.position
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
        cameraInterface.position.x += 10
        // set the scene to the view
        scnView.scene = scene
        scnView.delegate = self
        scnView.pointOfView = startCamera
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playButtonNode.isHidden = true
        animatePeople()
        animateSpotLights()
        animateCamera()
        let titleText = titleNode.geometry as! SCNText
        titleText.font = UIFont(name: titleText.font.fontName, size: 10)!
        titleNode.worldPosition.z = -2

        titleText.string = "PREPARE FOR THE SHOW!"
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4){ [self] in
            titleText.font = UIFont(name: titleText.font.fontName, size: 20)!

            titleNode.worldPosition.z = 0
            titleText.string = "3"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                titleText.string = "2"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    titleText.string = "1"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.appRouter.router = .arView
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                            self.gameState.showMetronome = true
                            self.gameState.showChordIndicator = true
                        }
                    }
                }
            }
        }
    }
    
    func animateCamera(){
        cameraInterface.runAction(SCNAction.sequence([
            SCNAction.wait(duration: 5),
            SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 2)]))
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
}

#Preview {
    ShowIntroView(appRouter: AppRouter(), gameState: GameState())
}
