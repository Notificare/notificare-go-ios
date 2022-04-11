//
//  EventsView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 08/04/2022.
//

import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel: EventsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: EventsViewModel())
    }
    
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
                ForEach($viewModel.attributes) { attribute in
                    HStack(spacing: 8) {
                        TextField(
                            String(localized: "events_attributes_attribute_name"),
                            text: attribute.key
                        )
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        TextField(
                            String(localized: "events_attributes_attribute_value"),
                            text: attribute.value
                        )
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
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
        .navigationTitle(String(localized: "events_title"))
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
