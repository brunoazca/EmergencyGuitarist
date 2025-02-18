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
    
    let scene = SCNScene(named: "IntroScene.scn")!
    let leftEyebrow = SCNScene(named: "IntroScene.scn")!.rootNode.childNode(withName: "EyebrowL", recursively: true)!
    
    let scnView:SCNView
    
    init(size: CGSize, appRouter: AppRouter) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
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
        print(self.leftEyebrow.position)
        leftEyebrow.position = SCNVector3(x: 10, y: 0, z: 10)
        leftEyebrow.runAction(SCNAction.sequence([SCNAction.move(by: SCNVector3(x: 100, y: 10, z: 100), duration: 3), SCNAction.run{_ in
            print(self.leftEyebrow.position)

        }]))
    }
}
