//
//  XPC.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/9/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Foundation
import XPC
import os

class HelperXPCService: HelperXPCProtocol {
    func helloWorld(_ callback: @escaping (String) -> Void) {
        callback("Hello World from the helper!!!")
    }
    
    func getVersion(_ callback: @escaping (String) -> Void) {
        callback(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0")
    }
    
    func ping(_ callback: @escaping () -> Void) {
        callback()
    }
}


class HelperXPCDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        os_log("NEW CONNECTION!!!!!")
        do {
            if try CodesignCheck.codeSigningMatches(pid: newConnection.processIdentifier) {
                let exportedObject = HelperXPCService()
                newConnection.exportedInterface = NSXPCInterface(with: HelperXPCProtocol.self)
                newConnection.exportedObject = exportedObject
                newConnection.resume()
                return true
            }
        } catch {
            return false
        }
                
        return false
    }
    
    
}

// main
os_log("Hello World!!")
os_log("Hello World!!!")
os_log("Hello World!!!!")


let delegate = HelperXPCDelegate()
let listener = NSXPCListener.init(machServiceName: "turtlmkr.desktopify.helper")
listener.delegate = delegate
listener.resume()

RunLoop.current.run()

