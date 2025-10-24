//
//  ProductsListView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 14/03/2022.
//

import SwiftUI
import OSLog
import ActitoKit

struct ProductsListView: View {
    @StateObject private var viewModel: ProductsListViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ProductsListViewModel())
    }
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                NavigationLink {
                    ProductDetailsView(product: product)
                } label: {
                    HStack {
                        AsyncImageCompat(url: URL(string: product.imageUrl)) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 64, height: 64 * 10 / 16)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading) {
                            Text(verbatim: product.name)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text(verbatim: product.description)
                                .font(.caption)
                                .lineLimit(2)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Text(verbatim: product.price.asCurrencyString())
                            .font(.headline)
                    }
                }
            }
        }
        .customListStyle()
        .navigationTitle(String(localized: "products_list_title"))
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.products)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsListView()
    }
}
