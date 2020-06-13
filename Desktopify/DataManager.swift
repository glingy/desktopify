//
//  DataManager.swift
//  Desktopify
//
//  Created by Gregory Ling on 5/3/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Foundation

struct CONFIG {
    static let KEYS = "config_keys"        // key 0 is none
    static let DESKTOPS = "config_desktops"
    static let DESKTOP_BOOKMARK = "config_desktop_bookmark"
    static let DESKTOPS_BOOKMARK = "config_desktops_url"
}

class DataManager {
    static let shared = DataManager()
    static let ALLOWED_KEYS : [Int] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 111] // Function keys excluding F11 (show Desktop)
    
    func getDesktopsURL() -> URL? {
        //print("Desktops URL!")
        return UserDefaults.standard.url(forKey: CONFIG.DESKTOPS_BOOKMARK)
    }
    
    func saveDesktopsURL(_ url: URL) {
        UserDefaults.standard.set(url, forKey: CONFIG.DESKTOPS_BOOKMARK)
    }
}
