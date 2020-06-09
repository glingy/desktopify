//
//  DesktopsManager.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa
import UserNotifications

enum DesktopError: Error {
    case DesktopNotEmptyError
}

class Desktop : ObservableObject {
    let id: Int
    var name : String {
        get {
            return DataManager.shared.getDesktop(byId: id)
        }
    }
    
    @Published var key: Int {
        didSet {
            if (oldValue != key) {
                if (key != 0 && DataManager.shared.hasKey(key) && DataManager.shared.getKey(byId: id) != key) {
                    key = oldValue
                } else {
                    DataManager.shared.setKey(forId: id, toKey: key)
                }
            }
        }
    }
    
    init(id: Int) {
        self.id = id
        self.key = DataManager.shared.getKey(byId: id)
    }
}

class DesktopsManager {
    static let shared = DesktopsManager()
    let desktopsDir = URL(fileURLWithPath: "Desktops", relativeTo: FileManager.default.homeDirectoryForCurrentUser)
    var cached : [Desktop]?
    
    func getDesktops() -> [Desktop]? {
        if (cached != nil) {
            return cached
        }
        
        do {
            var desktops = [Desktop]()
            var absent: [String] = DataManager.shared.getAllDesktops()
            
            let contents = try FileManager.default.contentsOfDirectory(at: desktopsDir, includingPropertiesForKeys: [.customIconKey, .isDirectoryKey], options: [.includesDirectoriesPostOrder, .skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            
            try contents.forEach { (desktop) in
                if (try desktop.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false) {
                    if (!DataManager.shared.hasDesktop(desktop.lastPathComponent)) {
                        DataManager.shared.addDesktop(named: desktop.lastPathComponent)
                    } else {
                        absent.remove(at: absent.firstIndex(of: desktop.lastPathComponent)!)
                    }
                }
            }
            
            for absentee in absent {
                DataManager.shared.removeDesktop(byName: absentee)
            }
            
            for i in (0..<DataManager.shared.count()) {
                desktops.append(Desktop(id: i))
            }
            
            DataManager.shared.sort()

            return desktops
        } catch {
            print("Error!")
            print(error)
        }
        return nil
    }
    
    func getDesktop() -> URL? {
        do {
            return try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            print(error)
            return nil
        }
    }
    
    func removeDesktop() -> Bool {
        guard let desktop = getDesktop() else { return false }
        
        do {
            if (try desktop.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile ?? false) {
                try FileManager.default.removeItem(at: desktop)
                return true
            }
        } catch CocoaError.fileReadNoSuchFile {
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func shouldForceRemoveDesktop() throws -> Bool  {
        guard let desktop = getDesktop() else { return false }
        
        // if it's an alias, we can remove it later, so no need to request sudo
        do {
            if (try desktop.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile ?? false) {
                return false
            } else {
                // Now we know it's a folder. Is it empty except for .localized and .DS_Store?
                if (try FileManager.default.contentsOfDirectory(atPath: desktop.absoluteString).first(where: { (name) -> Bool in
                    name != ".localized" && name != ".DS_Store"
                }) != nil) {
                    // If there's a file, then we shouldn't remove it, but throw an error to exit the program.
                    throw DesktopError.DesktopNotEmptyError
                }
                return true
            }
        } catch CocoaError.fileReadNoSuchFile { // if it doesn't exist, we're good
            return false
        } catch CocoaError.fileNoSuchFile { // if it doesn't exist, we're good
            return false
        } catch {
            print(error)
            throw DesktopError.DesktopNotEmptyError
        }
    }
    
    func swapTo(_ id: Int) {
        if (removeDesktop()) {
            do {
                try FileManager.default.createSymbolicLink(at: getDesktop()!, withDestinationURL: URL(fileURLWithPath: DataManager.shared.getDesktop(byId: id), relativeTo: desktopsDir))
            } catch {
                print(error)
            }
        }
    }
    
    func forceRemoveDesktopIfNeeded() throws {
        let content = UNMutableNotificationContent()
        content.title = "Error Starting Desktopify!"
        content.body = "Please manually remove the desktop folder."
        
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil), withCompletionHandler: nil)
    }
}
