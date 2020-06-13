//
//  CoreApplication.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/10/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Foundation


class CoreApplication {
    init() {
        do {
            let desktop = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            DesktopsManager.prepareDesktopFolder(desktop)
            
            //print("Manager")
            let _ = DesktopsManager(desktop)
            //print("Menu Item!")
            OperationQueue.main.addOperation {
                let _ = DesktopMenuItem()
            }
        } catch {print(error)}
        
        
    }
}
