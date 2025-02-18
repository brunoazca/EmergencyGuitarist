import SwiftUI

struct ContentView: View {
    @StateObject var appRouter: AppRouter = AppRouter()
    var body: some View {
        ZStack{
            switch appRouter.router {
            case .introScene:
                IntroView(appRouter: appRouter)
            case .arView:
                GuitarView(appRouter: appRouter)
            }
        }.animation(.linear, value: appRouter.router)
    }
}

enum Router{
    case introScene
    case arView
}

class AppRouter: ObservableObject {
    @Published var router: Router = .arView
}

