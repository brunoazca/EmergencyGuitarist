import SwiftUI

struct ContentView: View {
    @StateObject var appRouter: AppRouter = AppRouter()
    @StateObject var gameState = GameState()
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

