//
//  NotificareButton.swift
//  Notificare Go
//
//  Created by João Ferreira on 19/08/2025.
//

import SwiftUI

struct StyledButton<Label: View>: View {
    private let action: () -> Void
    private let label: Label

    init(_ title: String, action: @escaping () -> Void) where Label == Text {
        self.action = action
        self.label = Text(title)
    }

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                label
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
        } else {
            Button(action: action) {
                label
            }
            .buttonStyle(PrimaryButton())
        }
    }
}

