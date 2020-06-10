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
    func permissionsError(_ msg: Error)
    func permissionsSuccess()
}

class Permissions {
    private enum Status {
        case DESKTOPS, HELPER, KEYINPUT, SUCCESS;
        var label: String {
            switch self {
                //case .DESKTOP: return "Please open your Desktop folder:"
                case .DESKTOPS: return "Please select the folder in which to put the desktops:"
                case .HELPER: return "Please accept the helper:"
                case .KEYINPUT: return "(Optional) Give keyboard access for global shortcuts:"
                case .SUCCESS: return "All done!"
            }
        }
        var button: String {
            switch self {
                //case .DESKTOP: return "Open Desktop"
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
    
    private static var desktopBookmark: Data?
    
    public static func getDesktopBookmark() -> Data? {
        return desktopBookmark
    }
    
    private static var desktopsBookmark: Data?
    
    public static func getDesktopsBookmark() -> Data? {
        return desktopsBookmark
    }
    
    private static func getPermisson(_ delegate: PermissionsDelegate, _ status: Status) {
        OperationQueue.main.addOperation {
            permissions = Permissions(delegate)
            permissions!.setStatus(status)
            permissions!.showInfoPane()
        }
    }
    
    private static func hasDesktopsPermisson() -> Bool {
        if let desktopsB = DataManager.shared.getDesktopsBookmark() {
            desktopsBookmark = desktopsB
            return true
        }
        
        return false
    }

    public static func attempt(_ delegate: PermissionsDelegate) {
        if hasDesktopsPermisson() {
            Helper.connect { success in
                if success {
                    if AXIsProcessTrusted() {
                        delegate.permissionsSuccess()
                    } else {
                        getPermisson(delegate, .KEYINPUT)
                    }
                } else {
                    getPermisson(delegate, .HELPER)
                }
            }
        } else {
            getPermisson(delegate, .DESKTOPS)
        }
    }
    
    let delegate: PermissionsDelegate
    
    private init(_ delegate: PermissionsDelegate) {
        self.delegate = delegate
    }
    
    @IBAction public func nextButton(_ sender: NSButton) {
        //if (status == .DESKTOP || status == .DESKTOPS) {
        if (status == .DESKTOPS) {
            print("OPENED")
            guard window != nil else { return }
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            //panel.canCreateDirectories = status == .DESKTOPS
            panel.canCreateDirectories = true
            panel.prompt = "Suggested placement: ~/Desktops"
            panel.allowsMultipleSelection = false
            panel.beginSheetModal(for: window!) { (response) in
                print(response)
                if (response == .OK && panel.url != nil) {
                    print(panel.url as Any)
                    do {
                        let bookmark = try panel.url!.bookmarkData()
                        //if (self.status == .DESKTOP) {
                        //    DataManager.shared.saveDesktopBookmark(bookmark)
                        //    self.setStatus(.DESKTOPS)
                        //} else {
                            DataManager.shared.saveDesktopsBookmark(bookmark)
                            self.setStatus(.HELPER)
                        //}
                    } catch {
                        print(error)
                        self.statusLabel?.stringValue = "Unknown error. Please try again:"
                    }
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
        } else if (status == .HELPER) {
            blessHelper()
        } else {
            print("CLOSING!...")
            window?.close()
            delegate.permissionsSuccess()
        }
    }
    
    private func blessHelper() {
        let item = AuthorizationItem(name: (kSMRightBlessPrivilegedHelper as NSString).utf8String!, valueLength: 0, value: nil, flags: 0)
        var authItemPointer = UnsafeMutablePointer<AuthorizationItem>.allocate(capacity: 1)
        authItemPointer.initialize(to: item)
        defer {
            authItemPointer.deinitialize(count: 1)
            authItemPointer.deallocate()
        }
        var rights = AuthorizationRights(count: 1, items: authItemPointer)
        var environment = AuthorizationEnvironment(count: 0, items: nil)
        var authRef: AuthorizationRef? = nil
        let flags: AuthorizationFlags = [
            .interactionAllowed,
            .preAuthorize,
            .extendRights
        ]
        let status = AuthorizationCreate(&rights, &environment, flags, &authRef)
        print(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil))
        if let envItems = environment.items {
            envItems.deinitialize(count: Int(environment.count))
            envItems.deallocate()
        }
        
        if (status == errAuthorizationSuccess) {
            var err: Unmanaged<CFError>? = nil
            SMJobBless(kSMDomainSystemLaunchd, "turtlmkr.desktopify.helper" as CFString, authRef!, &err)
            print(err?.takeRetainedValue() as Any)
            statusLabel.stringValue = "Attempting to connect to helper..."
            Helper.connect { success in
                OperationQueue.main.addOperation {
                    if (success) {
                        self.setStatus(.SUCCESS)
                    } else {
                        self.statusLabel.stringValue = "There was an internal error. Please try again:"
                    }
                }
            }
        } else {
            statusLabel.stringValue = "There was an error.Please try again:"
        }
    }
    
    private func showInfoPane() {
        guard let nib = NSNib(nibNamed: "InfoPane", bundle: nil) else { return }
        print(nib.instantiate(withOwner: self, topLevelObjects: nil))
        setStatus(status)
        window?.makeKeyAndOrderFront(nil)
    }
}
