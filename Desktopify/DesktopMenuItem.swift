//
//  DesktopMenuItem.swift
//  Desktopify
//
//  Created by Gregory Ling on 4/17/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa

class DesktopMenuItem : NSMenuItem {
    //private let desktop: Desktop;
    
    
    
    /*init(_ desktop: Desktop) {
        self.desktop = desktop
        super.init(title: desktop.name(), action: #selector(swapTo(_:)), keyEquivalent: "")
        
        
        //keyEquivalentModifierMask =
    }*/
    
    required init(coder: NSCoder) {
       // self.desktop = Desktop(path: URL(fileURLWithPath: ""), keys: "")
        super.init(coder: coder)
    }
}
