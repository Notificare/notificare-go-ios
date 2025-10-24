//
//  EventsView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 08/04/2022.
//

import SwiftUI
import OSLog
import ActitoKit

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        List {
            Section {
                TextField(String(localized: "events_name_section"), text: $viewModel.name)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } header: {
                Text(String(localized: "events_name_section"))
            }
            
            Section {
                ForEach(viewModel.attributes) { attribute in
                    AttributeEditView(attribute: attribute)
                }
            } header: {
                Text(String(localized: "events_attributes_section"))
            } footer: {
                Button(String(localized: "events_attributes_add_button")) {
                    viewModel.attributes.append(EventsViewModel.Attribute(key: "", value: ""))
                }
                .disabled(viewModel.loading)
            }
            
            Section {
                Button(String(localized: "events_submit_button")) {
                    viewModel.logEvent()
                }
                .disabled(viewModel.loading)
            }
        }
        .customListStyle()
        .navigationTitle(String(localized: "events_title"))
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.events)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}

private struct AttributeEditView: View {
    @ObservedObject var attribute: EventsViewModel.Attribute

    var body: some View {
        HStack(spacing: 8) {
            TextField(
                String(localized: "events_attributes_attribute_name"),
                text: $attribute.key
            )
            .keyboardType(.default)
            .autocapitalization(.none)
            .disableAutocorrection(true)

            TextField(
                String(localized: "events_attributes_attribute_value"),
                text: $attribute.value
            )
            .keyboardType(.default)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
    }
}
