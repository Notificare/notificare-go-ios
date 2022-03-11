//
//  ProductCardView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 21/02/2022.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImageCompat(url: URL(string: product.imageUrl)) { image in
                Image(uiImage: image)
                    .resizable()
            } placeholder: {
                Color.clear
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(product.name)
                .font(.headline)
            
            Text(priceFormatter.string(from: NSNumber(value: product.price))!)
                .font(.caption)
        }
    }
    
    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        
        return formatter
    }()
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(product: .sample)
    }
}
