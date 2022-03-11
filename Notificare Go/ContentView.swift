//
//  ContentView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = ContentRouter.main
    
    var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView()
            case .intro:
                IntroView()
            case .main:
                MainView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ContentRouter: ObservableObject {
    static let main = ContentRouter(.splash)
    
    @Published var route: Route
    
    init(_ route: Route) {
        self.route = route
    }
    
    enum Route {
        case splash
        case intro
        case main
    }
}
