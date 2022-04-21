//
//  View+Theme.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 21/04/2022.
//

import SwiftUI

extension List {
    @ViewBuilder
    func customListStyle() -> some View {
        if #available(iOS 15.0, *) {
            listStyle(.insetGrouped)
        } else {
            listStyle(.grouped)
        }
    }
}
