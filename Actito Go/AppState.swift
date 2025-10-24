//
//  AppState.swift
//  Actito Go
//
//  Created by Helder Pinhal on 21/06/2022.
//

import Combine
import Foundation
import OSLog
import FirebaseAuth

class AppState: ObservableObject {
    @Published var contentTab: ContentTab = .home
    @Published var showEvents = false
    @Published var showProducts = false
    @Published var showInbox = false
    @Published var showUserProfile = false
    
    @Published private(set) var authenticationStateAvailable = false
    @Published private(set) var currentUser: UserInfo?
    
    typealias AuthenticationStatePublisher = AnyPublisher<Bool, Never>
    
    private var authenticationStateHandle: AuthStateDidChangeListenerHandle? = nil
    
    enum ContentTab {
        case home
        case cart
        case settings
    }
    
    init() {
        self.authenticationStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            Logger.main.info("Authentication state changed.")
            self?.authenticationStateAvailable = true
            
            if let user = user {
                self?.currentUser = UserInfo(user: user)
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    deinit {
        if let authenticationStateHandle = authenticationStateHandle {
            Auth.auth().removeStateDidChangeListener(authenticationStateHandle)
        }
    }
}
