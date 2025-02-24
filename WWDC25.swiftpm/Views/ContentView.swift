import SwiftUI

struct ContentView: View {
    @StateObject var appRouter: AppRouter = AppRouter()
    @StateObject var gameState = GameState()
    @State private var showAlert = true // Estado para mostrar o alerta

    
    var body: some View {
        ZStack{
            switch appRouter.router {
            case .introScene:
                IntroView(appRouter: appRouter)
            case .arView:
                GuitarView(appRouter: appRouter, gameState: gameState)
            case .showIntro:
                ShowIntroView(appRouter: appRouter, gameState: gameState)
            case .finalScene:
                FinalView(appRouter: appRouter)
            }
        }.animation(.linear, value: appRouter.router)
            .onAppear{
                gameState.appRouter = appRouter
            }
            .alert("Device Orientation", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    
                    } message: {
                        Text("Please rotate your device to Landscape Left for the best experience. The app will not function in any other orientation."
                             
            )
                    }
    }
}

enum Router{
    case introScene
    case arView
    case showIntro
    case finalScene
}

class AppRouter: ObservableObject {
    @Published var router: Router = .introScene
}

