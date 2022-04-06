//
//  IntroView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import AuthenticationServices
import SwiftUI
import Introspect
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
                IntroSlideView(slide: .intro) {
                    Button(String(localized: "intro_welcome_button")) {
                        withAnimation {
                            currentTab += 1
                        }
                    }
                    .buttonStyle(PrimaryButton())
                }
                .tag(0)
                
                IntroSlideView(slide: .notifications) {
                    Button(String(localized: "intro_notifications_button")) {
                        Notificare.shared.push().enableRemoteNotifications { _ in
                            // TODO: handle error scenario.
                            withAnimation {
                                currentTab += 1
                            }
                        }
                    }
                    .buttonStyle(PrimaryButton())
                }
                .tag(1)
                
                IntroSlideView(slide: .login) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.email, .fullName]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let auth):
                                print("Authorization successful")
                                
                                let user = CurrentUser(credential: auth.credential as! ASAuthorizationAppleIDCredential)
                                Keychain.standard.user = user
                                
                                Notificare.shared.device().register(userId: user.id, userName: user.name) { _ in
                                    // TODO: handle error scenario.
                                    Preferences.standard.introFinished = true
                                    ContentRouter.main.route = .main
                                }
                            case .failure(let error):
                                print("Authorization failed")
                                print("\(error)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                    .frame(height: 50)
                }
                .tag(2)
            }
            .tabViewStyle(.page)
            .introspectPagedTabView { collectionView, scrollView in
                scrollView.bounces = false
                scrollView.isScrollEnabled = false
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

private struct IntroSlideView<Footer: View>: View {
    private let slide: Slide
    private let footer: () -> Footer
    
    init(slide: Slide, @ViewBuilder footer: @escaping () -> Footer) {
        self.slide = slide
        self.footer = footer
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(slide.artwork)
                .resizable()
                .scaledToFit()
                .frame(height: 192)
                .padding()
            
            Text(slide.title)
                .font(.title)
                .lineLimit(1)
                .padding(.horizontal)
                .padding(.top, 32)
            
            Text(slide.message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Spacer()
            
            footer()
                .padding(32)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

extension IntroSlideView where Footer == EmptyView {
    init(slide: Slide) {
        self.init(slide: slide, footer: { EmptyView() })
    }
}
