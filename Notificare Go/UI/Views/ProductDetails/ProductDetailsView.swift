//
//  ProductDetails.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI

struct ProductDetailsView: View {
    @StateObject private var viewModel: ProductDetailsViewModel
    private let product: Product
    
    init(product: Product) {
        self._viewModel = StateObject(wrappedValue: ProductDetailsViewModel())
        self.product = product
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AsyncImageCompat(url: URL(string: product.imageUrl)) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
                .frame(height: 300)
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: product.name)
                        .font(.title)
                    
                    Text(verbatim: product.price.asCurrencyString())
                        .font(.subheadline)
                    
                    Text(verbatim: String(localized: "product_details_product_info"))
                        .font(.headline)
                        .padding(.top, 32)
                    
                    Text(verbatim: product.description)
                        .font(.subheadline)
                    
                    Button {
                        viewModel.addToCart(product)
                    } label: {
                        Label(String(localized: "product_details_add_to_cart"), systemImage: "cart.badge.plus")
                    }
                    .disabled(viewModel.cartCommand == .loading)
                    .buttonStyle(PrimaryButton())
                    .padding(.top, 16)
                }
                .padding()
            }
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    CartView()
                } label: {
                    Image(systemName: "cart")
                }
            }
        }
    }
}

struct ProductDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductDetailsView(product: .sample)
        }
    }
}
