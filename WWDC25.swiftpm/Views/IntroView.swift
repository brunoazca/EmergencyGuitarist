//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 18/02/25.
//

import Foundation
import SwiftUI

struct IntroView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        GeometryReader{ geo in
            IntroSceneViewControllerRepresentable(size: geo.size, appRouter: appRouter)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    IntroView(appRouter: AppRouter())
}
