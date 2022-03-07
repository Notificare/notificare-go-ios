//
//  MainView+ViewModel.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import Foundation
import SwiftUI

extension MainView {
    @MainActor class ViewModel: ObservableObject {
        @Published var viewState: ViewState = .splash
        
        func refresh() {
            viewState = .splash
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.viewState = .intro
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewState = .main
            }
        }
    }
    
    enum ViewState {
        case splash
        case intro
        case main
    }
}
