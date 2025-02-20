//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 19/02/25.
//

import Foundation

import SceneKit

extension SCNVector3 {
    // Somar dois vetores
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    // Subtrair dois vetores
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    // Multiplicação por um escalar (para ajustar a intensidade do movimento)
    static func *(vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    // Comprimento (magnitude) do vetor
    var length: Float {
        return sqrtf(x * x + y * y + z * z)
    }

    // Normalizar um vetor (magnitude = 1)
    func normalized() -> SCNVector3 {
        return length > 0 ? self * (1 / length) : SCNVector3(0, 0, 0)
    }
}
