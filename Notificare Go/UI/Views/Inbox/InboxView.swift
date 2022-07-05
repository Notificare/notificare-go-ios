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
    @State private var actionableItem: NotificareInboxItem?
    
    init() {
        self._viewModel = StateObject(wrappedValue: InboxViewModel())
    }
    
    var body: some View {
        ZStack {
            if viewModel.sections.isEmpty {
                Text(String(localized: "inbox_empty_message"))
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .padding(.all, 32)
            } else {
                List {
                    ForEach(viewModel.sections, id: \.group) { section in
                        Section {
                            ForEach(section.items) { item in
                                InboxItemView(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        handleOpenInboxItem(item)
                                    }
                                    .onLongPressGesture {
                                        actionableItem = item
                                    }
                            }
                        } header: {
                            Text(verbatim: getSectionHeader(section))
                        }
                    }
                }
                .customListStyle()
            }
        }
        .navigationTitle(String(localized: "inbox_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if !viewModel.sections.isEmpty {
                    Button(action: handleMarkAllItemsAsRead) {
                        Image(systemName: "envelope.open")
                    }
                    
                    Button(action: handleClearItems) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .actionSheet(item: $actionableItem) { item in
            ActionSheet(
                title: Text(String(localized: "inbox_options_dialog_title")),
                message: Text(item.notification.message),
                buttons: [
                    .default(Text(String(localized: "inbox_options_dialog_open"))) {
                        handleOpenInboxItem(item)
                    },
                    .default(Text(String(localized: "inbox_options_dialog_mark_as_read"))) {
                        handleMarkItemAsRead(item)
                    },
                    .destructive(Text(String(localized: "inbox_options_dialog_remove"))) {
                        handleRemoveItem(item)
                    },
                    .default(Text(String(localized: "shared_dialog_button_cancel"))) { }
                ]
            )
        }
        .onAppear {
            Task {
                do {
                    try await Notificare.shared.events().logPageView(.inbox)
                } catch {
                    Logger.main.error("Failed to log a custom event. \(error.localizedDescription)")
                }
            }
        }
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
    
    private func handleOpenInboxItem(_ item: NotificareInboxItem) {
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
    
    private func handleMarkItemAsRead(_ item: NotificareInboxItem) {
        Task {
            do {
                try await Notificare.shared.inbox().markAsRead(item)
            } catch {
                Logger.main.error("Failed to mark an item as read. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleMarkAllItemsAsRead() {
        Task {
            do {
                try await Notificare.shared.inbox().markAllAsRead()
            } catch {
                Logger.main.error("Failed to mark all item as read. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleRemoveItem(_ item: NotificareInboxItem) {
        Task {
            do {
                try await Notificare.shared.inbox().remove(item)
            } catch {
                Logger.main.error("Failed to remove an item. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleClearItems() {
        Task {
            do {
                try await Notificare.shared.inbox().clear()
            } catch {
                Logger.main.error("Failed to clear the inbox. \(error.localizedDescription)")
            }
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
