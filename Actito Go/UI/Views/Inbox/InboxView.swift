//
//  InboxView.swift
//  Actito Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import SwiftUI
import ActitoKit
import ActitoInboxKit
import ActitoPushUIKit
import OSLog

struct InboxView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: InboxViewModel
    @State private var actionableItem: ActitoInboxItem?

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
                                    .contextMenu {
                                        createContextMenu(for: item)
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
        .onAppear {
            Task {
                do {
                    try await Actito.shared.events().logPageView(.inbox)
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

    private func createContextMenu(for item: ActitoInboxItem) -> some View {
        Group {
            Button {
                handleOpenInboxItem(item)
            } label: {
                Label(String(localized: "inbox_options_dialog_open"), systemImage: "envelope.open")
            }

            Button {
                handleMarkItemAsRead(item)
            } label: {
                Label(String(localized: "inbox_options_dialog_mark_as_read"), systemImage: "checkmark")
            }

            Button(role: .destructive) {
                handleRemoveItem(item)
            } label: {
                Label(String(localized: "inbox_options_dialog_remove"), systemImage: "trash")
            }

            Button { } label: {
                Label(String(localized: "shared_dialog_button_cancel"), systemImage: "xmark")
            }
        }
    }

    private func handleOpenInboxItem(_ item: ActitoInboxItem) {
        // Pop the inbox view from the back stack when presenting deep links.
        // This lets the deep link navigate correctly to places like the inbox itself, settings, profile, etc.
        if item.notification.type == ActitoNotification.NotificationType.urlScheme.rawValue {
            presentationMode.wrappedValue.dismiss()
            
            // Trigger the deep link after a small delay, allowing the pop animation to complete.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentInboxItem(item)
            }
            
            return
        }
        
        presentInboxItem(item)
    }
    
    private func handleMarkItemAsRead(_ item: ActitoInboxItem) {
        Task {
            do {
                try await Actito.shared.inbox().markAsRead(item)
            } catch {
                Logger.main.error("Failed to mark an item as read. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleMarkAllItemsAsRead() {
        Task {
            do {
                try await Actito.shared.inbox().markAllAsRead()
            } catch {
                Logger.main.error("Failed to mark all item as read. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleRemoveItem(_ item: ActitoInboxItem) {
        Task {
            do {
                try await Actito.shared.inbox().remove(item)
            } catch {
                Logger.main.error("Failed to remove an item. \(error.localizedDescription)")
            }
        }
    }
    
    private func handleClearItems() {
        Task {
            do {
                try await Actito.shared.inbox().clear()
            } catch {
                Logger.main.error("Failed to clear the inbox. \(error.localizedDescription)")
            }
        }
    }
    
    private func presentInboxItem(_ item: ActitoInboxItem) {
        Task {
            do {
                let notification = try await Actito.shared.inbox().open(item)
                UIApplication.shared.present(notification)
            } catch {
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
