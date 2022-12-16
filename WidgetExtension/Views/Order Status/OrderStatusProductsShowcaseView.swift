//
//  OrderStatusProductsShowcaseView.swift
//  WidgetExtension
//
//  Created by Helder Pinhal on 14/12/2022.
//

import SwiftUI
import WidgetKit

@available(iOS 16.1, *)
struct OrderStatusProductsShowcaseView: View {
    let products: [Product]

    var body: some View {
        VStack(alignment: .trailing) {
            HStack(spacing: -8) {
                ForEach(showcasedProducts) { product in
                    Group {
                        if let image = LiveActivitiesImageDownloader.shared.image(for: product) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .background(Circle().fill(.white))
                    .overlay {
                        Circle()
                            .strokeBorder(Color("color_light_grey"), lineWidth: 2)
                    }
                }
            }

            Text(remainingProductsLabel)
                .font(.caption)
                .opacity(remainingProducts > 0 ? 1 : 0)
        }
    }

    private var showcasedProducts: [Product] {
        Array(products.prefix(3))
    }

    private var remainingProducts: Int {
        products.count - showcasedProducts.count
    }

    private var remainingProductsLabel: String {
        let localizationKey = NSLocalizedString("order_status_remaining_products", comment: "")
        return String(format: localizationKey, remainingProducts)
    }
}

@available(iOS 16.1, *)
struct OrderStatusProductsShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        OrderStatusProductsShowcaseView(
            products: [
                .init(id: "1", name: "A", description: "", price: 0, imageUrl: "", highlighted: false),
                .init(id: "2", name: "B", description: "", price: 0, imageUrl: "", highlighted: false),
                .init(id: "3", name: "C", description: "", price: 0, imageUrl: "", highlighted: false),
                .init(id: "4", name: "D", description: "", price: 0, imageUrl: "", highlighted: false),
            ]
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
