//
//  Night_Prayers_MacOSApp.swift
//  Night Prayers MacOS
//
//  Created by Joseph Hayes on 08/01/2025.
//

import SwiftUI
import AppKit
import Firebase

@main
struct Night_Prayers_MacOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // No need for a main app window, as this is a menu bar app
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Firebase
        configureFirebase()

        // Disable saved state restoration
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")

        // Create the popover
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        popover?.behavior = .transient // Auto-dismiss when clicking outside

        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sun.max.fill", accessibilityDescription: "Night Prayers")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    // Helper function to initialize Firebase
    private func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Firebase initialized successfully.")
        } else {
            print("Firebase is already configured.")
        }
    }
}
