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
    var isTouched = false {didSet{
        if(isTouched){
            geometry?.firstMaterial?.emission.intensity = 10
            geometry?.firstMaterial?.selfIllumination.intensity = 10
        } else{
            geometry?.firstMaterial?.emission.intensity = 0
            geometry?.firstMaterial?.selfIllumination.intensity = 0
        }
    }}
    var touchTimer: DispatchWorkItem?

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
        let sphere = SCNSphere(radius: 0.019)
        self.geometry = sphere
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.contents = color
        
        self.geometry?.materials = [material]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTouchTimer(){
        touchTimer = DispatchWorkItem { [weak self] in
            self?.isTouched = false
            
        }
    }
}
