//
//  AppDelegate.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var store = ClipBoardStore()
    private var monitor: ClipBoardMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // hide from dock — background app only
        NSApp.setActivationPolicy(.accessory)

        // configure the shared panel with our store
        ClipBoardPanel.shared.configure(with: store)

        // start monitoring clipboard
        monitor = ClipBoardMonitor(store: store)
        monitor?.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor?.stop()
    }
}
