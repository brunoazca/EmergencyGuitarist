//
//  SceneViewControllerRepresentable.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//

import Foundation

import SwiftUI
import UIKit

struct ARSceneViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:ARSceneViewController
    
    init(size:CGSize, appRouter: AppRouter, gameState: GameState) {
        viewController = ARSceneViewController(size: size, appRouter: appRouter, gameState: gameState)
    }
    
    func makeUIViewController(context: Context) -> ARSceneViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARSceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ARSceneViewController
    
    
}
