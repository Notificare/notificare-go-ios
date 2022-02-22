//
//  MainView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
