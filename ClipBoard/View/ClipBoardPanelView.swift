//
//  ClipBoardPanelView.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import SwiftUI

struct ClipBoardPanelView: View {
    @State private var store: ClipBoardStore
    @State private var searchQuery: String = ""
    @State private var items: [ClipBoardItem] = []

    init(store: ClipBoardStore) {
        self._store = State(initialValue: store)
    }

    var body: some View {
        VStack(spacing: 0) {
            // search bar
            SearchBarView(query: $searchQuery)
                .padding(10)

            Divider()

            // clip list
            if items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(items, id: \.id) { item in
                            ClipBoardRowView(item: item) {
                                select(item)
                            } onPin: {
                                store.togglePin(item)
                                refresh()
                            } onDelete: {
                                store.delete(item)
                                refresh()
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }

            Divider()

            // footer
            HStack {
                Text("\(items.count) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear All") {
                    store.clearAll(keepPinned: true)
                    refresh()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 380, height: 500)
        .background(.ultraThinMaterial)
        .onChange(of: searchQuery) { _, query in
            items = store.search(query)
        }
        .onAppear {
            refresh()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clipboard")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text(searchQuery.isEmpty ? "Nothing copied yet" : "No results found")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func select(_ item: ClipBoardItem) {
        // will wire to PasteManager in next step
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        ClipBoardPanel.shared.hide()
    }

    private func refresh() {
        items = store.search(searchQuery)
    }
}
