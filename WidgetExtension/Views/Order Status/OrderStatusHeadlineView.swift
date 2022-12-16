//
//  OrderStatusHeadlineView.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 14/12/2022.
//

import SwiftUI
import WidgetKit

struct OrderStatusHeadlineView: View {
    let state: OrderActivityAttributes.OrderState

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.footnote)
        }
    }

    private var title: String {
        switch state {
        case .preparing:
            return String(localized: "order_headline_preparing_title")

        case .shipped:
            return String(localized: "order_headline_shipped_title")

        case .delivered:
            return String(localized: "order_headline_delivered_title")
        }
    }

    private var subtitle: String {
        switch state {
        case .preparing:
            return String(localized: "order_headline_preparing_subtitle")

        case .shipped:
            return String(localized: "order_headline_shipped_subtitle")

        case .delivered:
            return String(localized: "order_headline_delivered_subtitle")
        }
    }
}

struct OrderStatusHeadlineView_Previews: PreviewProvider {
    static var previews: some View {
        OrderStatusHeadlineView(
            state: .preparing
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
