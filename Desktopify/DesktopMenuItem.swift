//
//  DesktopMenuItem.swift
//  Desktopify
//
//  Created by Gregory Ling on 4/17/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa

class DesktopMenuItem {
    public static var shared: DesktopMenuItem?
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let beforeDesktopsItem = NSMenuItem.separator()
    private let afterDesktopsItem = NSMenuItem.separator()
    
    private let DESKTOPS_STARTING_INDEX = 2
    
    
    
    init() {
        DesktopMenuItem.shared = self
        menu.addItem(withTitle: "Desktops", action: nil, keyEquivalent: "")
        menu.addItem(beforeDesktopsItem)
        menu.addItem(afterDesktopsItem)
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Desktopify", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        updateDesktopsList()

        statusItem.menu = menu
        statusItem.button?.image = NSImage(named:NSImage.Name("FolderIcon"))
        //print("Menu created!")
    }

    public func updateDesktopsList() {
        let firstOldDesktop = menu.index(of: beforeDesktopsItem) + 1
        let lengthOfDesktops = menu.index(of: afterDesktopsItem) - firstOldDesktop
        for _ in 0..<lengthOfDesktops {
            menu.removeItem(at: firstOldDesktop)
        }
        
        DesktopsManager.shared?.desktops.enumerated().forEach({ (i, desktop) in
            let item = desktop.menuItem
            menu.insertItem(item, at: firstOldDesktop + i)
        })
    }
}
