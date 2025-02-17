//
//  targetSphereNode.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 08/02/25.
//

import Foundation
import SceneKit
import ARKit

class TargetSphereNode: SCNNode {
    let finger: Finger
    let color: UIColor
    var isTouched = false
    
    init(finger: Finger) {
        self.finger = finger
        switch finger {
            case .index:
                color = UIColor.blue
            case .middle:
                color = UIColor.orange
            case .ring:
                color = UIColor.purple
        }
        
        super.init()
        let sphere = SCNSphere(radius: 0.017)
        self.geometry = sphere
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        

        self.geometry?.materials = [material]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
