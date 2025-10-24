//
//  AlertBlock.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct AlertBlock<Content: View>: View {
    private let type: AlertType
    private let title: String?
    private let systemImage: String?
    private let content: Content
    
    private var backgroundColor: Color {
        switch type {
        case .warning:
            return Color("color_alert_warning_background")
        case .error:
            return Color("color_alert_error_background")
        }
    }
    
    private var borderColor: Color {
        switch type {
        case .warning:
            return Color("color_alert_warning_border")
        case .error:
            return Color("color_alert_error_background")
        }
    }
    
    init(type: AlertType = .warning, title: String? = nil, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.type = type
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                if let systemImage = systemImage {
                    Label(title, systemImage: systemImage)
                        .font(.headline)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    enum AlertType {
        case warning
        case error
    }
}

struct AlertBlock_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AlertBlock(title: "Lorem ipsum", systemImage: "exclamationmark.triangle") {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque gravida sed sem nec consectetur. Quisque urna sem, rhoncus non consequat et, lacinia sit amet libero.")
            }
            
            AlertBlock(type: .error, title: "Lorem ipsum", systemImage: "exclamationmark.triangle") {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque gravida sed sem nec consectetur. Quisque urna sem, rhoncus non consequat et, lacinia sit amet libero.")
            }
        }
        .padding()
        
        VStack {
            AlertBlock(title: "Lorem ipsum", systemImage: "exclamationmark.triangle") {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque gravida sed sem nec consectetur. Quisque urna sem, rhoncus non consequat et, lacinia sit amet libero.")
            }
            
            AlertBlock(type: .error, title: "Lorem ipsum", systemImage: "exclamationmark.triangle") {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque gravida sed sem nec consectetur. Quisque urna sem, rhoncus non consequat et, lacinia sit amet libero.")
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}
