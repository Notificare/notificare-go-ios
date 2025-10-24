//
//  ProductDetails.swift
//  Actito Go
//
//  Created by Helder Pinhal on 22/02/2022.
//

import SwiftUI
import OSLog
import ActitoKit

struct ProductDetailsView: View {
    @StateObject private var viewModel: ProductDetailsViewModel
    
    init(product: Product) {
        self._viewModel = StateObject(wrappedValue: ProductDetailsViewModel(product: product))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AsyncImageCompat(url: URL(string: viewModel.product.imageUrl)) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 10 / 16)
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: viewModel.product.name)
                        .font(.title)
                    
                    Text(verbatim: viewModel.product.price.asCurrencyString())
                        .font(.subheadline)
                    
                    Text(verbatim: String(localized: "product_details_product_info"))
                        .font(.headline)
                        .padding(.top, 32)
                    
                    Text(verbatim: viewModel.product.description)
                        .font(.subheadline)

                    Button {
                        viewModel.addToCart()
                    } label: {
                        Label(String(localized: "product_details_add_to_cart"), systemImage: "cart.badge.plus")
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .adaptivePrimaryButton()
                    .disabled(viewModel.cartCommand == .loading)
                    .padding(.top, 16)
                }
                .padding()
            }
        }
        .navigationTitle(viewModel.product.name)
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
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.productDetails)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
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
