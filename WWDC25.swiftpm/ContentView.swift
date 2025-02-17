import SwiftUI

struct ContentView: View {
    @StateObject var appRouter: AppRouter = AppRouter()
    var body: some View {
        ZStack{
            switch appRouter.router {
            case .sceneView:
                GuitarView(appRouter: appRouter)
            }
        }.animation(.linear, value: appRouter.router)
    }
}

enum Router{
    case sceneView
}

class AppRouter: ObservableObject {
    @Published var router: Router = .sceneView
}

