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
                    Label(String(localized: "main_navigation_home"), systemImage: "house.fill")
                }
            
            CartView()
                .tabItem {
                    Label(String(localized: "main_navigation_cart"), systemImage: "cart.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label(String(localized: "main_navigation_settings"), systemImage: "gear")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
