//
//  File.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 23/02/25.
//

import Foundation
import SwiftUI

struct FinalView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        GeometryReader{ geo in
            FinalSceneViewControllerRepresentable(size: geo.size, appRouter: appRouter)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FinalView(appRouter: AppRouter())
}
