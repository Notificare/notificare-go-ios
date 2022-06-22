//
//  AppState.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 21/06/2022.
//

import Foundation

class AppState: ObservableObject {
    @Published var contentTab: ContentTab = .home
    @Published var showEvents = false
    @Published var showProducts = false
    @Published var showInbox = false
    @Published var showUserProfile = false
    
    enum ContentTab {
        case home
        case cart
        case settings
    }
}
