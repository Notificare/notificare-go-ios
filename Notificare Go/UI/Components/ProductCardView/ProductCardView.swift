//
//  ProductCardView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 21/02/2022.
//

import SwiftUI

struct ProductCardView: View {
    var body: some View {
        // image
        // label
        // price
        
        VStack(alignment: .leading) {
            Image(getImage())
                .resizable()
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text("Headphones")
                .font(.headline)
            
            Text("300€")
                .font(.caption)
        }
    }
    
    private func getImage() -> String {
        let i = Int.random(in: 0...1)
        if i == 0 {
            return "ProductHeadphones"
        }
        
        return "ProductNike"
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductCardView()
    }
}
