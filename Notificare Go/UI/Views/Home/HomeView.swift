//
//  HomeView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var navigationBarHidden: Bool = true
    
    private var user = Keychain.standard.user!
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            if let name = user.name {
                                Text(String(localized: "home_welcome_user_named", name))
                                    .font(.largeTitle)
                                    .bold()
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text(String(localized: "home_welcome_user"))
                                    .font(.largeTitle)
                                    .bold()
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                UserProfileView()
                            } label: {
                                AsyncImageCompat(url: user.gravatarUrl) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                } placeholder: {
                                    Color.clear
                                }
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                            }
                        }
                        .padding()
                        
                        TopProductsView(products: viewModel.highlightedProducts)
                            .padding()
                        
                        GroupBox {
                            VStack(alignment: .leading, spacing: 8) {
                                Label(String(localized: "home_scan_title"), systemImage: "barcode.viewfinder")
                                    .font(.headline)
                                
                                Text(String(localized: "home_scan_message"))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button(String(localized: "home_scan_button")) {
                                    //
                                }
                                .buttonStyle(PrimaryButton())
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading) {
                            Text(String(localized: "home_nearby_title"))
                                .font(.title2)
                                .bold()
                            
                            AlertBlock(title: String(localized: "home_nearby_alert_permissions_title"), systemImage: "exclamationmark.triangle") {
                                Text(String(localized: "home_nearby_alert_permissions_message"))
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Button {
                                    //
                                } label: {
                                    Text(String(localized: "home_nearby_alert_permissions_button"))
                                }
                            }
                        }
                        .padding()
                    }
                    
                    GeometryReader { proxy in
                        let offset = -proxy.frame(in: .named("scroll")).origin.y
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    }
                }
            }
            .navigationTitle(String(localized: "home_title"))
            .navigationBarHidden(navigationBarHidden)
            .navigationBarTitleDisplayMode(.inline)
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                let navigationBarHidden = value < 64
                if (navigationBarHidden != self.navigationBarHidden) {
                    self.navigationBarHidden = navigationBarHidden
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    struct ScrollViewOffsetPreferenceKey: PreferenceKey {
        typealias Value = CGFloat
        
        static var defaultValue: CGFloat = .zero
        
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value += nextValue()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
        HomeView().preferredColorScheme(.dark)
    }
}
