//
//  SceneView.swift
//  WWDC25
//
//  Created by Bruno Azambuja Carvalho on 27/01/25.
//

import Foundation
import SwiftUI
import SpriteKit

var arview: ARSceneViewControllerRepresentable? = nil

struct GuitarView: View{
    @ObservedObject var appRouter: AppRouter
    @State var startMetronome = false
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                makeARScene(size: geo.size, appRouter: appRouter)
//                SpriteKitViewRepresentable(size: geo.size, appRouter: appRouter)
//                       .frame(width: geo.size.width, height: geo.size.height)
//                       .background(Color.clear)
//                       .allowsHitTesting(true)
                
            }.ignoresSafeArea()
           
            if(startMetronome){
                VStack{
                    HStack{
                        CountdownRing()
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            GuitarLabelView(startMetronome: $startMetronome)
               
        }
    }
    func makeARScene(size: CGSize, appRouter: AppRouter)->ARSceneViewControllerRepresentable{
        let arViewRep = arview ?? ARSceneViewControllerRepresentable(size: size, appRouter: appRouter)
        arview = arViewRep
        return arview!
    }
}

#Preview {
    GuitarView(appRouter: AppRouter())
}
    

