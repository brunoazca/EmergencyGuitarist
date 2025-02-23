//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 23/02/25.
//

import SwiftUI
import UIKit

struct ShowIntroSceneViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:ShowIntroSceneViewController
    
    init(size:CGSize, appRouter: AppRouter, gameState: GameState) {
        viewController = ShowIntroSceneViewController(size: size, appRouter: appRouter, gameState: gameState)
    }
    
    func makeUIViewController(context: Context) -> ShowIntroSceneViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ShowIntroSceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ShowIntroSceneViewController
}
