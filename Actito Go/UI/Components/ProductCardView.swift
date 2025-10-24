//
//  ProductCardView.swift
//  Actito Go
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
                    .scaledToFill()
            } placeholder: {
                Color.clear
            }
            .frame(width: 128, height: 128 * 10 / 16)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(verbatim: product.name)
                .font(.headline)
            
            Text(verbatim: product.price.asCurrencyString())
                .font(.subheadline)
        }
        .frame(width: 128)
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView(product: .sample)
    }
}
