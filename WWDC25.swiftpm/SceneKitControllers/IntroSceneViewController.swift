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
    var leftEyebrow: SCNNode
    
    let scnView:SCNView
    
    init(size: CGSize, appRouter: AppRouter) {
        self.scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        leftEyebrow = scene.rootNode.childNode(withName: "EyebrowL", recursively: true)!

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
        

        leftEyebrow.isPaused = false
        
        print(self.leftEyebrow.position)
        leftEyebrow.runAction(SCNAction.move(by: SCNVector3(x: 10, y: 10, z: 10), duration: 5))
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                  print("Nova posição:", self.leftEyebrow.position)
                              }
    }
}
#Preview {
    IntroView(appRouter: AppRouter())
}
