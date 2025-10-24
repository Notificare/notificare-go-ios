//
//  CartItemView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 15/03/2022.
//

import SwiftUI

struct CartItemView: View {
    let item: CartEntry
    
    var body: some View {
        HStack {
            AsyncImageCompat(url: URL(string: item.product.imageUrl)) { image in
                Image(uiImage: image)
                    .resizable()
            } placeholder: {
                Color.clear
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(verbatim: item.product.name)
                    .font(.headline)
                
                Text(verbatim: item.product.price.asCurrencyString())
                    .font(.subheadline)
            }
        }
    }
}

struct CartItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = CartEntry(
            id: .init(),
            time: .init(),
            product: .sample
        )
        
        CartItemView(item: item)
        
        CartItemView(item: item)
            .preferredColorScheme(.dark)
    }
}
