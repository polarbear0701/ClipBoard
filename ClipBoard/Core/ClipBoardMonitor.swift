//
//  ClipBoardMonitor.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import AppKit
import Combine

@MainActor
@Observable
class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let store: ClipBoardStore
    
    var isRunning: Bool = false
    
    init(store: ClipBoardStore) {
        self.store = store
        self.lastChangeCount = NSPasteboard.general.changeCount
    }
    
    // MARK: - Lifecycle
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
        
        // make sure timer runs even when UI is tracking mouse
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    // MARK: - Detection

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        // handle text
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            let item = ClipBoardItem(content: text, contentType: .text)
            store.add(item)
            return
        }

        // handle image
        if let image = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: .png) {
            let item = ClipBoardItem(
                content: "[Image]",
                contentType: .image,
                imageData: image
            )
            store.add(item)
            return
        }

        // handle file paths
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            let paths = urls.map(\.path).joined(separator: "\n")
            let item = ClipBoardItem(content: paths, contentType: .file)
            store.add(item)
            return
        }
    }
}
