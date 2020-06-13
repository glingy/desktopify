//
//  Desktop.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/11/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa

class Desktop : ObservableObject {
    let name: String
    let menuItem: NSMenuItem
    
    @Published var key: Int {
        didSet {
            if (DesktopsManager.shared == nil) { return }
            if (oldValue != key) {
                if !uniqueKey(key) {
                    key = oldValue
                    return
                }
                
                saveKey(key)
                menuItem.keyEquivalent = KEY_MAP[key] == nil ? "" : String(utf16CodeUnits: [KEY_MAP[key]!], count: 1)
            }
        }
    }
    
    private func saveKey(_ key: Int) {
        guard let displayKey = DISPLAY_KEY_MAP.first(where: { (displayKey) -> Bool in
            displayKey.keyCode == key
        }), let keybindURL = getKeybindURL() else { return }
        
        do {
            try displayKey.name.write(to: keybindURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
        
    }
    
    private func uniqueKey(_ key: Int) -> Bool {
        return key == 0 || ((DesktopsManager.shared!.desktops.first(where: { (desktop) -> Bool in
            desktop.name != self.name && desktop.key == key
        })) == nil)
    }
    
    public func setActive(_ active: Bool) {
        menuItem.state = active ? .on : .off
    }
    
    @objc public func menuButtonClicked(_ sender: NSMenuItem) {
        print((sender.representedObject as? Desktop)?.name ?? "nil")
        DesktopsManager.shared?.swapTo(self)
    }
    
    private func getKeybindURL() -> URL? {
        return DesktopsManager.shared?.desktopsURL
            .appendingPathComponent(name)
            .appendingPathComponent(".desktopifyKeybind")
    }
    
    init(_ name: String) {
        //print("New desktop with name: \(name)")
        self.name = name
        key = 0
        
        menuItem = NSMenuItem(title: name, action: #selector(menuButtonClicked(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = self
        
        let keybindURL = getKeybindURL()
        if keybindURL != nil && FileManager.default.fileExists(atPath: keybindURL!.path) {
            do {
                //print("Contents of keybind file!")
                let string = try String(contentsOf: keybindURL!)
                let displayKey = DISPLAY_KEY_MAP.first { (key) -> Bool in
                    key.name == string
                }
                if displayKey != nil && uniqueKey(displayKey!.keyCode) {
                    key = displayKey!.keyCode
                }
            } catch {
                print(error)
            }
        }
        
        menuItem.keyEquivalentModifierMask = .init()
        menuItem.keyEquivalent = KEY_MAP[key] == nil ? "" : String(utf16CodeUnits: [KEY_MAP[key]!], count: 1)
    }
}
