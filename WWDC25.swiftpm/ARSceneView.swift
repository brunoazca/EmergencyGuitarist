//
//  SceneView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//

import Foundation
import SwiftUI

struct ARSceneView: View{
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        ZStack{
            GeometryReader { geo in
                ARSceneViewControllerRepresentable(size: geo.size, appRouter: appRouter)
            }.ignoresSafeArea()
        }
    }
}
