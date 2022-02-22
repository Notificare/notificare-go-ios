//
//  TopProductsView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 21/02/2022.
//

import SwiftUI

struct TopProductsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "home_top_products"))
                .font(.title2)
                .bold()
            
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ProductCardView()
                    ProductCardView()
                    ProductCardView()
                    ProductCardView()
                    ProductCardView()
                }
            }
            
            HStack {
                Spacer()
                
                Button {
                    //
                } label: {
                    HStack {
                        Text(String(localized: "home_top_products_browse_more_button"))
                        Image(systemName: "arrow.right")
                    }
                }
            }
        }
    }
}

struct TopProductsView_Previews: PreviewProvider {
    static var previews: some View {
        TopProductsView()
    }
}
