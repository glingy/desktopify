//
//  AppDelegate.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//
// See https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PermissionsDelegate {
    var coreApplication: CoreApplication?
    static let mainRunLoop = CFRunLoopGetCurrent()
    
    func permissionsComplete() {
        if (AXIsProcessTrusted()) {
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: {
                (event) in
                if (DataManager.ALLOWED_KEYS.contains(Int(event.keyCode))) {
                    guard let desktop = DesktopsManager.shared?.desktops.first(where: { (desktop) -> Bool in
                        desktop.key == event.keyCode
                    }) else { return }
                    
                    DesktopsManager.shared?.swapTo(desktop)
                }
            })
        }
        
        self.coreApplication = CoreApplication()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func showPreferences(_ sender: Any?) {
        if (window == nil && DesktopsManager.shared != nil) {
            window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
            window!.isReleasedWhenClosed = false
            window!.setFrameAutosaveName("AutoSave Name helps")
            window!.center()
            window!.contentView = NSHostingView(rootView: ContentView(desktops: DesktopsManager.shared!.desktops))
        }
        NSApp.activate(ignoringOtherApps: true)
        window!.makeKeyAndOrderFront(nil)
    }
    
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Permissions.attempt(self)
    }
}
