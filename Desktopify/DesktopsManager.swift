//
//  DesktopsManager.swift
//  Desktopify
//
//  Created by Gregory Ling on 3/16/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

import Cocoa
import UserNotifications
import CoreServices

class DesktopsManager {
    public var desktopsURL: URL
    private let desktopURL: URL
    private(set) public var desktops : [Desktop] = []
    private var fsEventStream : FSEventStreamRef?
    private(set) public static var shared: DesktopsManager?
    private(set) public var currentDesktop: Desktop?
    
    func addDesktop(_ name: String) {
        let index = desktops.firstIndex { (a) -> Bool in
            a.name > name
        }
        desktops.insert(Desktop(name), at: index ?? desktops.count)
        DesktopMenuItem.shared?.updateDesktopsList()
        // update preferences window
    }
    
    func removeDesktop(_ name: String) {
        guard let index = desktops.firstIndex(where: { (a) -> Bool in
            a.name == name
        }) else { return }
        desktops.remove(at: index)
        DesktopMenuItem.shared?.updateDesktopsList()
        // update preferences window
    }
    
    init(_ desktopURL: URL) {
        self.desktopURL = desktopURL
        desktopsURL = DataManager.shared.getDesktopsURL()!
        DesktopsManager.shared = self
        
        // Load desktops from the desktops folder and cached keybindings:
        loadDesktopsFromFolder()
        startFileWatcher()
        swapTo(desktops[0])
    }
    
    func loadDesktopsFromFolder() {
        do {
            desktops = []
            let contents = try FileManager.default.contentsOfDirectory(at: desktopsURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.includesDirectoriesPostOrder, .skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            
            try contents.forEach { (desktop) in
                if (try desktop.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false) {
                    desktops.append(Desktop(desktop.lastPathComponent))
                }
            }
            
            desktops.sort { (a, b) -> Bool in
                a.name < b.name // better sorting criteria?
            }

        } catch {
            print("Error!")
            print(error)
        }
    }
    
    func fileWatcherFolderChanged(_ streamRef: ConstFSEventStreamRef, _ clientCallbackInfo: UnsafeMutableRawPointer?, _ numEvents: Int, _ eventPaths: UnsafeMutableRawPointer, _ eventFlags: UnsafePointer<FSEventStreamEventFlags>, _ eventIds: UnsafePointer<FSEventStreamEventId>) {
        //print("File changed!!!")
        let paths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]
        
        var lastRenamed = false
        
        for i in 0 ..< numEvents {
            if lastRenamed {
                lastRenamed = false
                print(eventIds[i])
                print("Unknown:")
                print(paths[i])
            } // rename! - file renamed and file exists at renamed location?
            
            if (URL(fileURLWithPath: paths[i]).deletingLastPathComponent() == desktopsURL && eventFlags[i] & UInt32(kFSEventStreamEventFlagItemIsDir) != 0) {
                
                //print("Could be me!")
                //print(paths[i])
                //print(eventFlags[i])
                //print(eventIds[i])
                if (eventFlags[i] & UInt32(kFSEventStreamEventFlagItemRemoved) != 0) {
                    print("Removed: \(URL(fileURLWithPath: paths[i]).lastPathComponent)")
                    removeDesktop(URL(fileURLWithPath: paths[i]).lastPathComponent)
                } else if (eventFlags[i] & UInt32(kFSEventStreamEventFlagItemRenamed) != 0) {
                    print("Renamed: \(URL(fileURLWithPath: paths[i]).lastPathComponent)")
                    if (Util.folderExists(URL(fileURLWithPath: paths[i]))) {
                        addDesktop(URL(fileURLWithPath: paths[i]).lastPathComponent)
                    } else {
                        removeDesktop(URL(fileURLWithPath: paths[i]).lastPathComponent)
                    }
                } else if (eventFlags[i] & UInt32(kFSEventStreamEventFlagItemCreated) != 0) {
                    print("Created: \(URL(fileURLWithPath: paths[i]).lastPathComponent)")
                    addDesktop(URL(fileURLWithPath: paths[i]).lastPathComponent)
                }
                //determine(eventFlags[i])
            }
        }
    }
    
    func startFileWatcher() {

        let eventStream = FSEventStreamCreate(nil, {
            DesktopsManager.shared?.fileWatcherFolderChanged($0, $1, $2, $3, $4, $5)
        }, nil, Array(arrayLiteral: desktopsURL.path) as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), CFTimeInterval(0.5), FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents))
        
        if (eventStream == nil) {
            print("Error! EventStream is nil!")
            return
        }
        
        FSEventStreamScheduleWithRunLoop(eventStream!, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(eventStream!)
    }
    
    func swapTo(_ desktop: Desktop) {
        currentDesktop?.setActive(false)
        currentDesktop = desktop
        desktop.setActive(true)        
        
        if (Util.folderExists(desktopURL) && !Util.isAlias(desktopURL)) {
            print("ERROR! A DESKTOP FOLDER SHOULD NOT EXIST!")
            return
        }
        
        do {
            if FileManager.default.fileExists(atPath: desktopURL.path) {
                if Util.isAlias(desktopURL) {
                
                    try FileManager.default.removeItem(at: desktopURL)
                
                } else {
                    print("Error! A Desktop something exists and it's not a folder nor an alias! I'm confused.")
                    return
                }
            }
        
        // then make the new link
            try FileManager.default.createSymbolicLink(at: desktopURL, withDestinationURL:URL(fileURLWithPath: desktop.name, relativeTo: desktopsURL))
        } catch {
            print(error)
        }
    }
    
    
    public static func prepareDesktopFolder(_ desktopURL: URL) {
        if (Util.folderExists(desktopURL) && !Util.isAlias(desktopURL)) {
            
            // make sure we have permission to delete it...
            do {
                try Process.run(URL(fileURLWithPath: "/bin/chmod"), arguments: ["-a", "everyone deny delete", desktopURL.path]) { process in
                //print(process)
                }
            } catch {
                print(error)
            }
            
            // check for files we'd be destroying...
            // TODO: we need a menu to relocate files... for now if it's empty it'll do
            
            do {
                var isEmpty = true
                let contents = try FileManager.default.contentsOfDirectory(atPath: desktopURL.path)
                for item in contents {
                    if (item != ".DS_Store") {
                        isEmpty = false
                        break
                    }
                }
                
                if isEmpty {
                    deleteDesktopFolder(desktopURL)
                } else {
                    print("Not empty! Found some files: \(contents)")
                }
            } catch {
                print(error)
            }
        }
    }
    
    private static func deleteDesktopFolder(_ desktopURL: URL) {
        do {
            try FileManager.default.removeItem(at: desktopURL)
        } catch {
            print(error)
        }
    }
}



/*func determine(_ flags: FSEventStreamEventFlags) {
    var outStr = ""
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagNone)) > 0 ? "kFSEventStreamEventFlagNone\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagMount)) > 0 ? "kFSEventStreamEventFlagMount\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagUnmount)) > 0 ? "kFSEventStreamEventFlagUnmount\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagOwnEvent)) > 0 ? "kFSEventStreamEventFlagOwnEvent\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile)) > 0 ? "kFSEventStreamEventFlagItemIsFile\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir)) > 0 ? "kFSEventStreamEventFlagItemIsDir\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemChangeOwner)) > 0 ? "kFSEventStreamEventFlagItemChangeOwner\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) > 0 ? "kFSEventStreamEventFlagItemCreated\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) > 0 ? "kFSEventStreamEventFlagItemRemoved\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) > 0 ? "kFSEventStreamEventFlagItemRenamed\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) > 0 ? "kFSEventStreamEventFlagItemModified\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemXattrMod)) > 0 ? "kFSEventStreamEventFlagItemXattrMod\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsSymlink)) > 0 ? "kFSEventStreamEventFlagItemIsSymlink\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsHardlink)) > 0 ? "kFSEventStreamEventFlagItemIsHardlink\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsLastHardlink)) > 0 ? "kFSEventStreamEventFlagItemIsLastHardlink\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemInodeMetaMod)) > 0 ? "kFSEventStreamEventFlagItemInodeMetaMod\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemFinderInfoMod)) > 0 ? "kFSEventStreamEventFlagItemFinderInfoMod\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagHistoryDone)) > 0 ? "kFSEventStreamEventFlagHistoryDone\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagRootChanged)) > 0 ? "kFSEventStreamEventFlagRootChanged\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagMustScanSubDirs)) > 0 ? "kFSEventStreamEventFlagMustScanSubDirs\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagUserDropped)) > 0 ? "kFSEventStreamEventFlagUserDropped\n" : "")
    outStr += ((flags & FSEventStreamEventFlags(kFSEventStreamEventFlagKernelDropped)) > 0 ? "kFSEventStreamEventFlagKernelDropped\n" : "")
    print(outStr)
}
*/
