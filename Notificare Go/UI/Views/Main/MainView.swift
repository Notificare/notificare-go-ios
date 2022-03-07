//
//  MainView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .splash:
                ZStack(alignment: .center) {
                    Circle()
                        .foregroundColor(.orange)
                        .frame(width: 200, height: 200)
                    
                    Text("GO")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .intro:
                IntroView()

            case .main:
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    CartView()
                        .tabItem {
                            Label("Cart", systemImage: "cart.fill")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
