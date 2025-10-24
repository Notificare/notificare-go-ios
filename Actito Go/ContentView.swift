//
//  ContentView.swift
//  Actito Go
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
            case .scanner:
                AppScannerView()
            case .intro:
                IntroView()
            case .main:
                MainView()
            }
        }
        .environmentObject(router)
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
        case scanner
        case intro
        case main
    }
}
