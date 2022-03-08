//
//  HomeView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI

struct HomeView: View {
    @State var navigationBarHidden: Bool = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(localized: "home_welcome_user", "Helder"))
                                .font(.largeTitle)
                                .bold()
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            AsyncImageCompat(url: URL(string: "https://gravatar.com/avatar/1a73f51bd2d8f8114835508ecd678c66?s=400&d=blank")) { image in
                                Image(uiImage: image)
                                    .resizable()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        }
                        .padding()
                        
                        TopProductsView()
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
