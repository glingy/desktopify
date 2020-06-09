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
}

class DataManager {
    static let shared = DataManager()
    static let ALLOWED_KEYS : [Int] = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 111] // Function keys excluding F11 (show Desktop)
    
    private var keys : [Int] = []
    private var desktops : [String] = []

    init() {
        keys = getKeys() ?? []
        desktops = getDesktops() ?? []
        
        print(keys)
        print(desktops)
    }
    
    private func getKeys() -> [Int]? {
        return UserDefaults.standard.array(forKey: CONFIG.KEYS) as? [Int]
    }
    
    private func getDesktops() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: CONFIG.DESKTOPS)
    }
    
    func getAllDesktops() -> [String] {
        return desktops
    }
    
    func setKey(forDesktop desktop: String, toKey key: Int) {
        guard let id = desktops.firstIndex(of: desktop) else { return }
        keys[id] = key
        save()
    }
    
    func setKey(forId id: Int, toKey key: Int) {
        keys[id] = key
        save()
    }
    
    func addDesktop(named name: String, withKey key: Int = 0) {
        desktops.append(name)
        keys.append(key)
        guard keys.count == desktops.count else {
            print("Invalid state! Diffferent numbers of desktops and keys!")
            return
        }
        save()
    }
    
    func hasDesktop(_ name: String) -> Bool {
        return desktops.contains(name)
    }
    
    func hasKey(_ key: Int) -> Bool {
        return keys.contains(key)
    }
    
    func getId(named name: String) -> Int? {
        return desktops.firstIndex(of: name)
    }
    
    func getId(fromKey key: Int) -> Int? {
        return keys.firstIndex(of: key)
    }
    
    func getDesktop(byId id: Int) -> String {
        return desktops[id]
    }
    
    func getKey(byId id: Int) -> Int {
        return keys[id]
    }
    
    func removeDesktop(byName name: String) {
        guard let id = getId(named: name) else { return }
        keys.remove(at: id)
        desktops.remove(at: id)
    }
    
    func count() -> Int {
        return keys.count
    }
    
    func save() {
        UserDefaults.standard.set(keys, forKey: CONFIG.KEYS)
        UserDefaults.standard.set(desktops, forKey: CONFIG.DESKTOPS)
        print("SAVED!")
    }
    
    func sort() {
        let ids = Array(0..<keys.count).sorted { (i, j) -> Bool in
            desktops[i] < desktops[j]
        }
        
        var newD: [String] = [String](repeating: "", count: desktops.count)
        var newK: [Int] = [Int](repeating: 0, count: desktops.count)
        
        for (i, id) in ids.enumerated() {
            newD[i] = desktops[id]
            newK[i] = keys[id]
        }
        desktops = newD
        keys = newK
        save()
    }
}
