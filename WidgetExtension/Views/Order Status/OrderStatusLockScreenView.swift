//
//  OrderStatusLockScreenView.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 14/12/2022.
//

import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct OrderStatusLockScreenView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Image("artwork_logo_badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                OrderStatusHeadlineView(state: state.state)

                Spacer()

                OrderStatusProductsShowcaseView(products: attributes.products)
            }

            OrderStatusTrackerView(state: state.state)
        }
        .padding()
    }
}

@available(iOS 16.1, *)
struct OrderStatusLockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        OrderStatusLockScreenView(
            attributes: OrderActivityAttributes(
                products: [
                    .init(id: "1", name: "A", description: "", price: 0, imageUrl: "", highlighted: false),
                    .init(id: "2", name: "B", description: "", price: 0, imageUrl: "", highlighted: false),
                    .init(id: "3", name: "C", description: "", price: 0, imageUrl: "", highlighted: false),
                    .init(id: "4", name: "D", description: "", price: 0, imageUrl: "", highlighted: false),
                ]
            ),
            state: OrderActivityAttributes.ContentState(
                state: .shipped
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
