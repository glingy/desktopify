//
//  Util.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/12/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa

struct DisplayKey {
    let name : String
    let keyCode : Int
}

let DISPLAY_KEY_MAP : [DisplayKey] = [
    DisplayKey(name: "None", keyCode: 0),
    DisplayKey(name: "F1",   keyCode: 122),
    DisplayKey(name: "F2",   keyCode: 120),
    DisplayKey(name: "F3",   keyCode: 99),
    DisplayKey(name: "F4",   keyCode: 118),
    DisplayKey(name: "F5",   keyCode: 96),
    DisplayKey(name: "F6",   keyCode: 97),
    DisplayKey(name: "F7",   keyCode: 98),
    DisplayKey(name: "F8",   keyCode: 100),
    DisplayKey(name: "F9",   keyCode: 101),
    DisplayKey(name: "F10",  keyCode: 109),
    DisplayKey(name: "F12",  keyCode: 111)
]

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

class Util {
    public static func folderExists(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
    
    public static func isAlias(_ url: URL) -> Bool {
        do {
            return try url.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile ?? false
        } catch {
            print(error)
            print("Other error!")
            return false
        }
    }
}
