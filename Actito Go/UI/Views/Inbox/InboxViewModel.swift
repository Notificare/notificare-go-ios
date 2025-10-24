//
//  Inbox+ViewModel.swift
//  Actito Go
//
//  Created by Helder Pinhal on 02/03/2022.
//

import Combine
import Foundation
import ActitoKit
import ActitoInboxKit
import OSLog

@MainActor
class InboxViewModel: ObservableObject {
    @Published private(set) var sections: [InboxSection] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let items = Actito.shared.inbox().items
        self.sections = createSections(for: items)
        
        NotificationCenter.default
            .publisher(for: .inboxUpdated, object: nil)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                guard let items = notification.userInfo?["items"] as? [ActitoInboxItem] else {
                    Logger.main.error("Invalid notification payload.")
                    return
                }
                
                self.sections = self.createSections(for: items)
            }
            .store(in: &cancellables)
    }
    
    private func createSections(for items: [ActitoInboxItem]) -> [InboxSection] {
        var sections: [InboxSection] = []
        
        var filteredItems = items.filter { $0.time >= Date.today }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .today,
                    items: filteredItems
                )
            )
        }
        
        filteredItems = items.filter { $0.time >= Date.yesterday && $0.time < Date.today }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .yesterday,
                    items: filteredItems
                )
            )
        }
        
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date.today)!
        
        filteredItems = items.filter { $0.time >= sevenDaysAgo && $0.time < Date.yesterday }
        if !filteredItems.isEmpty {
            sections.append(
                InboxSection(
                    group: .lastSevenDays,
                    items: filteredItems
                )
            )
        }
        
        let remainingItems = Dictionary(
            grouping: items.filter { $0.time < sevenDaysAgo },
            by: { item in
                let month = Calendar.current.component(.month, from: item.time)
                let year = Calendar.current.component(.year, from: item.time)
                
                return InboxSection.Group.other(month: month, year: year)
            }
        ).map { key, value in
            InboxSection(
                group: key,
                items: value
            )
        }.sorted { lhs, rhs in
            if case let .other(lMonth, lYear) = lhs.group, case let .other(rMonth, rYear) = rhs.group {
                if lYear == rYear {
                    return lMonth > rMonth
                }
                
                return lYear > rYear
            }
            
            // should never happen.
            return false
        }
        
        sections.append(contentsOf: remainingItems)
        
        return sections
    }
    
    struct InboxSection: Identifiable {
        let group: Group
        let items: [ActitoInboxItem]
        
        var id: String {
            switch group {
            case .today:
                return "today"
            case .yesterday:
                return "yesterday"
            case .lastSevenDays:
                return "last_seven_days"
            case .other(let month, let year):
                return "other_\(year)_\(month)"
            }
        }
        
        enum Group: Hashable {
            case today
            case yesterday
            case lastSevenDays
            case other(month: Int, year: Int)
        }
    }
}
