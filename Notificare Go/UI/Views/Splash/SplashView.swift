//
//  SplashView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 10/03/2022.
//

import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel: SplashViewModel
    @State private var contentHeight = 0.0
    
    init() {
        self._viewModel = StateObject(wrappedValue: SplashViewModel())
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Text("Notificare GO!")
                .font(.title)
                .overlay(DetermineSize())
                .onPreferenceChange(SizePreferenceKey.self) { size in
                    contentHeight = size.height
                }
            
            if viewModel.isShowingProgress {
                ProgressView()
                    .offset(y: contentHeight + 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
