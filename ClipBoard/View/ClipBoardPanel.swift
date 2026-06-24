//
//  ClipBoardPanel.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import AppKit
import SwiftUI

class ClipBoardPanel: NSPanel {
    static let shared = ClipBoardPanel()
    private var store: ClipBoardStore?

    // MARK: - Init

    private init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 500),
            styleMask: [
                .nonactivatingPanel,  // won't steal focus from active app
                .fullSizeContentView,
                .borderless
            ],
            backing: .buffered,
            defer: false
        )

        setup()
    }

    private func setup() {
        // window behavior
        level = .floating
        isFloatingPanel = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // appearance
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // corner radius via hosting view
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 12
        contentView?.layer?.masksToBounds = true
    }

    // MARK: - Configure

    func configure(with store: ClipBoardStore) {
        self.store = store
        let view = ClipBoardPanelView(store: store)
        contentView = NSHostingView(rootView: view)

        // re-apply corner radius after setting contentView
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = 12
        contentView?.layer?.masksToBounds = true
    }

    // MARK: - Show / Hide

    func show() {
        guard let screen = NSScreen.main else { return }

        // center on screen, slightly above center
        let x = (screen.visibleFrame.width - frame.width) / 2 + screen.visibleFrame.minX
        let y = (screen.visibleFrame.height - frame.height) / 2 + screen.visibleFrame.minY + 60
        setFrameOrigin(NSPoint(x: x, y: y))

        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        orderOut(nil)
    }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    // MARK: - Keyboard handling

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: // Esc
            hide()
        default:
            super.keyDown(with: event)
        }
    }

    // clicking outside dismisses the panel
    override func resignKey() {
        super.resignKey()
        hide()
    }
}
