//
//  SceneView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//

import Foundation
import SwiftUI
import SpriteKit

struct GuitarView: View{
    @ObservedObject var appRouter: AppRouter
    @State var startMetronome = false
    
    var body: some View {
        ZStack{
            GeometryReader { geo in

                ARSceneViewControllerRepresentable(size: geo.size, appRouter: appRouter)
//                SpriteKitViewRepresentable(size: geo.size, appRouter: appRouter)
//                       .frame(width: geo.size.width, height: geo.size.height)
//                       .background(Color.clear)
//                       .allowsHitTesting(true)
                
            }.ignoresSafeArea()
           
            VStack{
                HStack{
                    CountdownRing()
                        .padding()
                    Spacer()
                }
                Spacer()
            }
            
            GuitarLabelView(startMetronome: $startMetronome)
               
        }
    }
}

#Preview {
    GuitarView(appRouter: AppRouter())
}
    

