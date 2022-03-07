//
//  InboxView.swift
//  Notificare Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import SwiftUI
import NotificareKit
import NotificareInboxKit
import NotificarePushUIKit

struct InboxView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.group) { section in
                Section {
                    ForEach(section.items) { item in
                        InboxItemView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                presentInboxItem(item)
                            }
                    }
                } header: {
                    Text(verbatim: getSectionHeader(section))
                }
            }
        }
        .navigationTitle(String(localized: "inbox_title"))
    }
    
    private func getSectionHeader(_ section: ViewModel.InboxSection) -> String {
        switch section.group {
        case .today:
            return String(localized: "inbox_section_today")
        case .yesterday:
            return String(localized: "inbox_section_yesterday")
        case .lastSevenDays:
            return String(localized: "inbox_section_last_seven_days")
        case let .other(month, year):
            let monthName = DateFormatter().monthSymbols[month - 1]
            
            if year == Calendar.current.component(.year, from: Date()) {
                return monthName
            }
            
            return "\(monthName) \(year)"
        }
    }
    
    private func presentInboxItem(_ item: NotificareInboxItem) {
        Notificare.shared.inbox().open(item) { result in
            switch result {
            case let .success(notification):
                UIApplication.shared.present(notification)
            case let .failure(error):
                print("Failed to open an inbox item. \(error)")
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
