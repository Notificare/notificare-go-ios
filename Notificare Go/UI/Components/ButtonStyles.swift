//
//  PrimaryButton.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color("color_primary"))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        Button("Click me") {
            
        }
        .buttonStyle(PrimaryButton())
    }
}
