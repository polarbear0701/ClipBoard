//
//  ClipBoardApp.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import SwiftUI

@main
struct ClipBoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // no main window — app lives in panel only
        Settings {
            EmptyView()
        }
    }
}
