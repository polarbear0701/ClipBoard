//
//  ClipBoardStore.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//
import SwiftData
import Foundation

@MainActor
@Observable
class ClipBoardStore {
    private let container: ModelContainer
    private let context: ModelContext
    
    let maxItems = 200
    let maxAgeDays = 90
    
    init () {
        let schema = Schema([ClipBoardItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
    
    func fetchAll() -> [ClipBoardItem] {
        let descriptor = FetchDescriptor<ClipBoardItem>()
        let items = (try? context.fetch(descriptor)) ?? []
        return items.sorted {
            if $0.isPinned != $1.isPinned { return $0.isPinned }
            return $0.createdAt > $1.createdAt
        }
    }
    
    func search(_ query: String) -> [ClipBoardItem] {
        guard !query.isEmpty else { return fetchAll() }
        let descriptor = FetchDescriptor<ClipBoardItem>(
            predicate: #Predicate { $0.content.contains(query) },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Write

    func add(_ item: ClipBoardItem) {
        // avoid duplicates — if same content exists, just update timestamp
        let existing = fetchAll().first { $0.content == item.content && $0.contentType == item.contentType }
        if let existing {
            existing.createdAt = Date()
            try? context.save()
            return
        }

        context.insert(item)
        try? context.save()
        prune()
    }

    func togglePin(_ item: ClipBoardItem) {
        item.isPinned.toggle()
        try? context.save()
    }

    func delete(_ item: ClipBoardItem) {
        context.delete(item)
        try? context.save()
    }

    func clearAll(keepPinned: Bool = true) {
        let items = fetchAll()
        for item in items {
            if keepPinned && item.isPinned { continue }
            context.delete(item)
        }
        try? context.save()
    }

    // MARK: - Prune

    private func prune() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxAgeDays, to: Date())!
        let all = fetchAll().filter { !$0.isPinned }  // never prune pinned

        // remove expired
        for item in all where item.createdAt < cutoffDate {
            context.delete(item)
        }

        // trim to maxItems if still over limit
        let unpinned = all.filter { $0.createdAt >= cutoffDate }
        if unpinned.count > maxItems {
            let toDelete = unpinned.suffix(unpinned.count - maxItems)
            toDelete.forEach { context.delete($0) }
        }

        try? context.save()
    }
    
}
