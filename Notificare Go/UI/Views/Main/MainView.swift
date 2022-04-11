//
//  MainView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct MainView: View {
    @Preference(\.storeEnabled)
    private var storeEnabled: Bool
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label(String(localized: "main_navigation_home"), systemImage: "house.fill")
            }
            
            if storeEnabled {
                NavigationView {
                    CartView()
                }
                .tabItem {
                    Label(String(localized: "main_navigation_cart"), systemImage: "cart.fill")
                }
            }
            
            NavigationView {
                SettingsView()
            }
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
