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
import OSLog

struct InboxView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: InboxViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: InboxViewModel())
    }
    
    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.group) { section in
                Section {
                    ForEach(section.items) { item in
                        InboxItemView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Pop the inbox view from the back stack when presenting deep links.
                                // This lets the deep link navigate correctly to places like the inbox itself, settings, profile, etc.
                                if item.notification.type == NotificareNotification.NotificationType.urlScheme.rawValue {
                                    presentationMode.wrappedValue.dismiss()
                                    
                                    // Trigger the deep link after a small delay, allowing the pop animation to complete.
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        presentInboxItem(item)
                                    }
                                    
                                    return
                                }
                                
                                presentInboxItem(item)
                            }
                    }
                } header: {
                    Text(verbatim: getSectionHeader(section))
                }
            }
        }
        .customListStyle()
        .navigationTitle(String(localized: "inbox_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getSectionHeader(_ section: InboxViewModel.InboxSection) -> String {
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
                Logger.main.error("Failed to open an inbox item. \(error.localizedDescription)")
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
