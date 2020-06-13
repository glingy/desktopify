//
//  DesktopPermission.swift
//  Desktopify
//
//  Created by Gregory Ling on 6/8/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa
import ServiceManagement

protocol PermissionsDelegate {
    func permissionsComplete()
}

class Permissions {
    private enum Status {
        case DESKTOP, DESKTOPS, HELPER, KEYINPUT, SUCCESS;
        var label: String {
            switch self {
                case .DESKTOP: return "Please open your Desktop folder:"
                case .DESKTOPS: return "Please select the folder in which to put the desktops:"
                case .HELPER: return "Please accept the helper:"
                case .KEYINPUT: return "(Optional) Give keyboard access for global shortcuts:"
                case .SUCCESS: return "All done!"
            }
        }
        var button: String {
            switch self {
                case .DESKTOP: return "Open Desktop"
                case .DESKTOPS: return "Open Desktops"
                case .HELPER: return "Install Helper"
                case .KEYINPUT: return "Next"
                case .SUCCESS: return "Celebrate!"
            }
        }
    }
    
    private var status: Status = .DESKTOPS
    
    private func setStatus(_ status: Status) {
        self.status = status
        statusLabel?.stringValue = status.label
        button?.title = status.button
    }
    
    private static var permissions: Permissions?
    
    @IBOutlet private weak var window: NSWindow!
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBAction func quitButton(_ sender: NSButton) {
        NSApp.terminate(nil)
    }
    
    private static var desktopsURL: URL?

    private static func getPermisson(_ delegate: PermissionsDelegate, _ status: Status) {
        OperationQueue.main.addOperation {
            permissions = Permissions(delegate)
            permissions!.setStatus(status)
            permissions!.showInfoPane()
        }
    }
    
    private static func hasDesktopsPermission() -> Bool {
        guard let desktopsURL = DataManager.shared.getDesktopsURL() else { return false }
        return Util.folderExists(desktopsURL)
    }

    public static func attempt(_ delegate: PermissionsDelegate) {
        if hasDesktopsPermission() {
            delegate.permissionsComplete()
        } else {
            getPermisson(delegate, .DESKTOPS)
        }
    }
    
    let delegate: PermissionsDelegate
    
    private init(_ delegate: PermissionsDelegate) {
        self.delegate = delegate
    }
    
    private static func showOpenPanel(creatingDirectories: Bool = false, _ callback: @escaping (NSApplication.ModalResponse, NSOpenPanel) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        //panel.canCreateDirectories = status == .DESKTOPS
        panel.canCreateDirectories = true
        //panel.prompt = "Suggested placement: ~/Desktops"
        panel.allowsMultipleSelection = false
        panel.begin(completionHandler: {
            callback($0, panel)
        })
    }
    
    @IBAction public func nextButton(_ sender: NSButton) {
        if (status == .DESKTOPS) {
            Permissions.showOpenPanel { (response, panel) in
                //print(response)
                if (response == .OK && panel.url != nil) {
                    //print(panel.url as Any)
                    DataManager.shared.saveDesktopsURL(panel.url!)
                } else {
                    self.statusLabel?.stringValue = "Invalid selection. Please try again:"
                }
            }
        } else if (status == .KEYINPUT) {
            if (!AXIsProcessTrusted()) {
              let opts : [AnyHashable: Any] = [
                  kAXTrustedCheckOptionPrompt.takeRetainedValue():   true
              ]
              print(AXIsProcessTrustedWithOptions(opts as CFDictionary))
            }
            setStatus(.SUCCESS)
        } else {
            print("CLOSING!...")
            window?.close()
            delegate.permissionsComplete()
        }
    }
    
    private func showInfoPane() {
        guard let nib = NSNib(nibNamed: "InfoPane", bundle: nil) else { return }
        print(nib.instantiate(withOwner: self, topLevelObjects: nil))
        setStatus(status)
        window?.makeKeyAndOrderFront(nil)
    }
}
