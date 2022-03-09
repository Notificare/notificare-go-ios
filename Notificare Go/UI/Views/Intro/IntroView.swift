//
//  IntroView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import AuthenticationServices
import SwiftUI
import NotificareKit

struct IntroView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentTab = 0
    @State private var loginButtonVisible = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .init(named: "color_intro_indicator_current")
        UIPageControl.appearance().pageIndicatorTintColor = .init(named: "color_intro_indicator_unselected")
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentTab) {
                IntroSlideView(slide: .intro)
                    .tag(0)
                
                IntroSlideView(slide: .notifications)
                    .tag(1)
                
                IntroSlideView(slide: .login)
                    .tag(2)
            }
            .tabViewStyle(.page)
            .onChange(of: currentTab) { newValue in
                // Show the login button on the third tab.
                loginButtonVisible = newValue == 2
                
                // Ask for permissions on the second tab.
                if newValue == 1 {
                    // TODO: handle the result.
                    Notificare.shared.push().enableRemoteNotifications { _ in }
                }
            }
            
            if loginButtonVisible {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let auth):
                            print("Authorization successful")
                            
                            guard let credentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                                return
                            }
                            
                            guard let tokenData = credentials.identityToken,
                                  let tokenStr = String(data: tokenData, encoding: .utf8)
                            else {
                                return
                            }
                            
                            print(tokenStr)
                            
                            var name: String? = nil
                            if let nameComponents = credentials.fullName {
                                var parts = [String]()
                                
                                if let givenName = nameComponents.givenName {
                                    parts.append(givenName)
                                }
                                
                                if let familyName = nameComponents.familyName {
                                    parts.append(familyName)
                                }
                                
                                if !parts.isEmpty {
                                    name = parts.joined(separator: " ")
                                }
                            }
                            
                            Notificare.shared.device().register(userId: credentials.user, userName: name) { result in
                                switch result {
                                case .success:
                                    break
                                case .failure:
                                    break
                                }
                            }
                            
                        case .failure(let error):
                            print("Authorization failed")
                            print("\(error)")
                        }
                    }
                )
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                    .frame(height: 50)
                    .padding(.bottom, 64)
                    .padding(.horizontal, 32)
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
        
        IntroView()
            .preferredColorScheme(.dark)
    }
}

private struct IntroSlideView: View {
    let slide: Slide
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(slide.artwork)
                .resizable()
                .scaledToFit()
                .padding()
            
            Text(slide.title)
                .font(.title)
                .lineLimit(1)
                .padding(.horizontal)
                .padding(.top, 48)
            
            Text(slide.message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
        }
    }
    
    enum Slide {
        case intro
        case notifications
        case login
        
        var artwork: String {
            switch self {
            case .intro:
                return "artwork_intro"
            case .notifications:
                return "artwork_remote_notifications"
            case .login:
                return "artwork_login"
            }
        }
        
        var title: String {
            switch self {
            case .intro:
                return String(localized: "intro_welcome_title")
            case .notifications:
                return String(localized: "intro_notifications_title")
            case .login:
                return String(localized: "intro_login_title")
            }
        }
        
        var message: String {
            switch self {
            case .intro:
                return String(localized: "intro_welcome_message")
            case .notifications:
                return String(localized: "intro_notifications_message")
            case .login:
                return String(localized: "intro_login_message")
            }
        }
    }
}
