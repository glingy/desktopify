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

let KEY_MAP : [Int : unichar] = [
    122: unichar(NSF1FunctionKey),
    120: unichar(NSF2FunctionKey),
    99: unichar(NSF3FunctionKey),
    118: unichar(NSF4FunctionKey),
    96: unichar(NSF5FunctionKey),
    97: unichar(NSF6FunctionKey),
    98: unichar(NSF7FunctionKey),
    100: unichar(NSF8FunctionKey),
    101: unichar(NSF9FunctionKey),
    109: unichar(NSF10FunctionKey),
    111: unichar(NSF11FunctionKey)
]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PermissionsDelegate {
    func permissionsError(_ msg: Error) {
        print(msg)
        exit(0)
    }
    
    func permissionsSuccess() {
        if let button = statusItem.button {
              button.image = NSImage(named:NSImage.Name("FolderIcon"))
            }
            
            constructMenu()
            NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: {
                (event) in
                if (DataManager.ALLOWED_KEYS.contains(Int(event.keyCode))) {
                    guard let id = DataManager.shared.getId(fromKey: Int(event.keyCode)) else { return }
                    
                    DesktopsManager.shared.swapTo(id)
                }
            })
            
            do {
                try DesktopsManager.shared.forceRemoveDesktopIfNeeded()
            } catch {
                print("Desktop Not Empty!")
                exit(1)
            }
        }

        func applicationWillTerminate(_ aNotification: Notification) {
            // Insert code here to tear down your application
        }
        
        func constructMenu() {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Desktops", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            DesktopsManager.shared.getDesktops()?.forEach({ (desktop) in
                let item = NSMenuItem(title: desktop.name, action: #selector(swapTo(_:)), keyEquivalent: KEY_MAP[desktop.key] != nil ? String(utf16CodeUnits: [KEY_MAP[desktop.key]!], count: 1) : "")
                item.keyEquivalentModifierMask = .init()
                item.representedObject = desktop.id
                menu.addItem(item)
            })
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Desktopify", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

          statusItem.menu = menu
        }
        
        @objc func swapTo(_ sender: Any?) {
            guard let id = (sender as? NSMenuItem)?.representedObject as? Int else { return }
            
            DesktopsManager.shared.swapTo(id)
        }
        
        @objc func showPreferences(_ sender: Any?) {
            if (window == nil) {
                window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
                window!.isReleasedWhenClosed = false
                window!.setFrameAutosaveName("AutoSave Name helps")
                window!.center()
                window!.contentView = NSHostingView(rootView: ContentView(desktops: DesktopsManager.shared.getDesktops()!))
            }
            NSApp.activate(ignoringOtherApps: true)
            window!.makeKeyAndOrderFront(nil)
    }
    
    
    

    var window: NSWindow?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Permissions.attempt(self)
    }
}
