//
//  PrimaryButton.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButtonView(configuration: configuration)
    }
    
    struct PrimaryButtonView: View {
        @Environment(\.isEnabled) private var isEnabled: Bool
        
        let configuration: PrimaryButton.Configuration
        
        var body: some View {
            configuration.label
                .background(isEnabled ? Color("color_primary") : Color.gray)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .animation(.easeInOut, value: isEnabled)
                .animation(.easeInOut, value: configuration.isPressed)
        }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button("Click me") {
                
            }
            .buttonStyle(PrimaryButton())
            
            Button("Click me") {
                
            }
            .buttonStyle(PrimaryButton())
            .disabled(true)
        }
    }
}
