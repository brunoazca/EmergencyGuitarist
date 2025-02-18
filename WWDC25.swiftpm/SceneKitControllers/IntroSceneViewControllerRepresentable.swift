//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//

import SwiftUI
import UIKit

struct IntroSceneViewControllerRepresentable: UIViewControllerRepresentable{
    let viewController:IntroSceneViewController
    
    init(size:CGSize, appRouter: AppRouter) {
        viewController = IntroSceneViewController(size: size, appRouter: appRouter)
    }
    
    func makeUIViewController(context: Context) -> IntroSceneViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: IntroSceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = IntroSceneViewController
}
