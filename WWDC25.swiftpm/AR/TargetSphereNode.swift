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
    var color: UIColor
    var isTouched = false
    
    init(finger: Finger) {
        self.finger = finger
        switch finger {
            case .index:
                color = UIColor(cgColor: CGColor(red: 0, green: 0.5, blue: 0.5, alpha: 1))
            case .middle:
                color = UIColor(cgColor: CGColor(red: 0.5, green: 0.5, blue: 0, alpha: 1))
            case .ring:
                color = UIColor(cgColor: CGColor(red: 0.5, green: 0, blue: 0.5, alpha: 1))


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
