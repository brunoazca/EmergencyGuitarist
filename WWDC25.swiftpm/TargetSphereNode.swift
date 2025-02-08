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
    var isTouched = false
    
    init(finger: Finger) {
        self.finger = finger
        super.init()
        let sphere = SCNSphere(radius: 0.015)
        self.geometry = sphere
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        self.geometry?.materials = [material]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
