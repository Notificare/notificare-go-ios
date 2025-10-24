//
//  MainView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    
    @Preference(\.storeEnabled)
    private var storeEnabled: Bool
    
    var body: some View {
        TabView(selection: $appState.contentTab) {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tag(AppState.ContentTab.home)
            .tabItem {
                Label(String(localized: "main_navigation_home"), systemImage: "house.fill")
            }
            
            if storeEnabled {
                NavigationView {
                    CartView()
                }
                .navigationViewStyle(.stack)
                .tag(AppState.ContentTab.cart)
                .tabItem {
                    Label(String(localized: "main_navigation_cart"), systemImage: "cart.fill")
                }
            }
            
            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(.stack)
            .tag(AppState.ContentTab.settings)
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
