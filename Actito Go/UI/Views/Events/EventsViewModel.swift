//
//  EventsViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 08/04/2022.
//

import Combine
import Foundation
import ActitoKit

@MainActor
class EventsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var name = ""
    @Published var attributes: [Attribute] = [Attribute(key: "", value: "")]

    @Published var loading = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false

    func logEvent() {
        Task {
            do {
                let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }

                self.loading = true

                var data: ActitoEventData = [:]

                attributes
                    .map {
                        Attribute(
                            key: $0.key.trimmingCharacters(in: .whitespacesAndNewlines),
                            value: $0.value.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                    .filter { !$0.key.isEmpty }
                    .forEach { data[$0.key] = $0.value }

                try await Actito.shared.events().logCustom(name, data: !data.isEmpty ? data : nil)

                self.name = ""
                self.attributes = [Attribute(key: "", value: "")]
                self.showingSuccessAlert = true
            } catch {
                self.showingErrorAlert = true
            }

            self.loading = false
        }
    }

    class Attribute: ObservableObject, Identifiable {
        let id = UUID()

        @Published var key: String
        @Published var value: String

        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }
}
