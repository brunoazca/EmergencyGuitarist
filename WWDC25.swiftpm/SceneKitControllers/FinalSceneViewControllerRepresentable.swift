//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//

import SwiftUI
import UIKit

struct FinalSceneViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:FinalSceneViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = FinalSceneViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> FinalSceneViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: FinalSceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = FinalSceneViewController
}
