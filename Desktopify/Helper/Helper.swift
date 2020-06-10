//
//  Helper.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/9/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa
import XPC

class Helper {
    private static var tool: HelperXPCProtocol? = nil
    private static var connection: NSXPCConnection? = nil
    
    public static func sameVersion(_ callback: @escaping (Bool) -> Void) {
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/turtlmkr.desktopify.helper")
        guard
            let helperVersion = (CFBundleCopyInfoDictionaryForURL(helperURL as CFURL) as? [String: Any])?["CFBundleShortVersionString"] as? String,
            let helper = tool
        else {
            callback(false)
            return
        }
        
        helper.getVersion { version in
            print("Installed version: ")
            print(version)
            print("Packaged version: ")
            print(helperVersion)
            callback(version == helperVersion)
        }
    }
    
    
    
    
    public static func connect(_ callback: @escaping (Bool) -> Void) {
        print("Connecting to helper tool!")
        connection = NSXPCConnection(machServiceName: "turtlmkr.desktopify.helper", options: .privileged)
        connection!.remoteObjectInterface = NSXPCInterface(with: HelperXPCProtocol.self)
        connection!.resume()
        
        var done = false // prevent calling both callbacks... shouldn't happen, but just in case
        
        tool = connection!.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error, error.localizedDescription)
            if (!done) {
                done = true
                callback(false)
            }
        } as? HelperXPCProtocol
        
        if tool == nil {
            print("Tool is nil!")
            callback(false)
            return
        }

        tool!.ping {
            print("Ping received!")
            if (!done) {
                done = true
                sameVersion { isSameVersion in
                    if (isSameVersion) {
                        print("Same versions!")
                        callback(true)
                    } else {
                        print("Different versions!")
                        disconnect()
                        callback(false)
                    }
                }
            }
        }
    }
    
    public static func disconnect() {
        if (connection != nil) {
            connection!.invalidate()
            connection = nil
        }
    }
}



