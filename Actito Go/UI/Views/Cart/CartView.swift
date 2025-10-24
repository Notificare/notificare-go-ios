//
//  CartView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 18/02/2022.
//

import SwiftUI
import ActitoKit
import OSLog

struct CartView: View {
    @StateObject private var viewModel: CartViewModel
    @Preference(\.cart) private var cart
    
    private var cartTotal: Double {
        cart.reduce(0.0) { accumulated, entry in
            accumulated + entry.product.price
        }
    }
    
    private var lastModifiedStr: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let mostRecentEntry = cart.max(by: { $0.time < $1.time })!
        
        return formatter.string(from: mostRecentEntry.time)
    }
    
    init() {
        self._viewModel = StateObject(wrappedValue: CartViewModel())
    }
    
    var body: some View {
        Group {
            if cart.isEmpty {
                CartEmptyView()
            } else {
                List {
                    Section {
                        ForEach(cart.sorted(by: { $0.time < $1.time })) { entry in
                            CartItemView(item: entry)
                                .contextMenu {
                                    if #available(iOS 15.0, *) {
                                        Button(role: .destructive) {
                                            viewModel.remove(entry)
                                        } label: {
                                            Label(String(localized: "cart_remove_item_button"), systemImage: "trash")
                                        }
                                    } else {
                                        Button {
                                            viewModel.remove(entry)
                                        } label: {
                                            Label(String(localized: "cart_remove_item_button"), systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    } header: {
                        Text(String(localized: "cart_disclaimer_message"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 32, trailing: 0))
                            .textCase(.none)
                    } footer: {
                        Text(verbatim: String(localized: "cart_last_modified", lastModifiedStr))
                    }
                    
                    Section {
                        Button(String(localized: "cart_purchase_button")) {
                            viewModel.purchase()
                        }
                        .disabled(viewModel.purchaseCommand == .loading)
                    } footer: {
                        Text(verbatim: String(localized: "cart_total_amount", cartTotal.asCurrencyString()))
                    }
                }
                .customListStyle()
            }
        }
        .navigationTitle(String(localized: "cart_title"))
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.cart)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}

struct CartEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: String(localized: "cart_empty_message"))
            
            NavigationLink {
                ProductsListView()
            } label: {
                Text(verbatim: String(localized: "cart_shop_button"))
            }
        }
    }
}
