//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 29/09/2022.
//

import SwiftUI
import WidgetKit

@main
struct NotificareGoWidgets: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            CoffeeBrewerLiveActivity()

//            OrderStatusActivityWidget()
        }
    }
}
