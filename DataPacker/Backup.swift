//
//  Backup.swift
//  DataPacker
//
//  Created by Hoyoun Song on 2020/08/07.
//

import Foundation
import Cocoa

public class Backup {
    
    @IBOutlet var LogView: NSTextView!
    
    var totalBackupSize = 0
    
    func setup(view: NSTextView) {
        LogView = view
    }
    
    private func log(isError: Bool, _ toLog: String){
        if isError {
            print("[-] \(toLog)")
            LogView.string += "[-] \(toLog)\n"
        }else{
            print("[*] \(toLog)")
            LogView.string += "[*] \(toLog)\n"
        }
        LogView.scrollToEndOfDocument(nil)
    }
    
    func queryStorage(source: String, destination: String) -> String {
        var destinationFreeUnit: UInt8
        var destinationFreeNum: UInt64
        
        var sourceSizeUnit: UInt8
        var sourceSizeNum: UInt64
        
        log(isError: false, "Asking shell for free space...")
        var destinationFree = NSSwiftUtils.runCommand("df" ,"-h", destination.replacingOccurrences(of: "/dpbackup.dpz", with: "")).output[1].replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").components(separatedBy: " ")[3]
        log(isError: false, "Shell returned: \(destinationFree.replacingOccurrences(of: "i", with: ""))")
        if destinationFree.hasSuffix("Ti") {
            destinationFreeUnit = 4
            destinationFree = destinationFree.replacingOccurrences(of: "Ti", with: "")
            if destinationFree.contains(".") {
                destinationFree = destinationFree.components(separatedBy: ".")[0]
            }
            destinationFreeNum = UInt64(destinationFree)!
        }else if destinationFree.hasSuffix("Gi") {
            destinationFreeUnit = 3
            destinationFree = destinationFree.replacingOccurrences(of: "Gi", with: "")
            if destinationFree.contains(".") {
                destinationFree = destinationFree.components(separatedBy: ".")[0]
            }
            destinationFreeNum = UInt64(destinationFree)!
        }else if destinationFree.hasSuffix("Mi") {
            destinationFreeUnit = 2
            destinationFree = destinationFree.replacingOccurrences(of: "Mi", with: "")
            if destinationFree.contains(".") {
                destinationFree = destinationFree.components(separatedBy: ".")[0]
            }
            destinationFreeNum = UInt64(destinationFree)!
        }else if destinationFree.hasSuffix("Ki") {
            destinationFreeUnit = 1
            destinationFree = destinationFree.replacingOccurrences(of: "Ki", with: "")
            if destinationFree.contains(".") {
                destinationFree = destinationFree.components(separatedBy: ".")[0]
            }
            destinationFreeNum = UInt64(destinationFree)!
        }else if destinationFree.hasSuffix("Bi") {
            destinationFreeUnit = 0
            destinationFree = destinationFree.replacingOccurrences(of: "Bi", with: "")
            if destinationFree.contains(".") {
                destinationFree = destinationFree.components(separatedBy: ".")[0]
            }
            destinationFreeNum = UInt64(destinationFree)!
        }else{
            log(isError: true, "Analysis failed.")
            return "ERROR: Size unrecognized. Perhaps disk space is larger than a terabyte?"
        }
        log(isError: false, "Destination query complete.")
        
        log(isError: false, "Asking shell for source (user) size...")
        var sourceSize = NSSwiftUtils.runCommand("du" ,"-ch", source).output.last!.components(separatedBy: " ")[1].components(separatedBy: "/")[0].replacingOccurrences(of: " ", with: "")
        log(isError: false, "Shell returned: \(sourceSize)")
        if sourceSize.contains("T") {
            sourceSizeUnit = 4
            sourceSize = sourceSize.components(separatedBy: "T")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum = UInt64(sourceSize)!
        }else if sourceSize.contains("G") {
            sourceSizeUnit = 3
            sourceSize = sourceSize.components(separatedBy: "G")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum = UInt64(sourceSize)!
        }else if sourceSize.contains("M") {
            sourceSizeUnit = 2
            sourceSize = sourceSize.components(separatedBy: "M")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum = UInt64(sourceSize)!
        }else if sourceSize.contains("K") {
            sourceSizeUnit = 1
            sourceSize = sourceSize.components(separatedBy: "K")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum = UInt64(sourceSize)!
        }else if sourceSize.contains("B") {
            sourceSizeUnit = 0
            sourceSize = sourceSize.components(separatedBy: "B")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum = UInt64(sourceSize)!
        }else{
            log(isError: true, "Analysis failed.")
            return "ERROR: Size unrecognized. Perhaps source is larger than a terabyte?"
        }
        
        log(isError: false, "Asking shell for source (apps) size...")
        sourceSize = NSSwiftUtils.runCommand("du" ,"-ch", "/Applications").output.last!.components(separatedBy: " ")[1].components(separatedBy: "/")[0].replacingOccurrences(of: " ", with: "")
        log(isError: false, "Shell returned: \(sourceSize)")
        if sourceSize.contains("T") {
            sourceSize = sourceSize.components(separatedBy: "T")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum += UInt64(sourceSize)!
        }else if sourceSize.contains("G") {
            sourceSize = sourceSize.components(separatedBy: "G")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum += UInt64(sourceSize)!
        }else if sourceSize.contains("M") {
            sourceSize = sourceSize.components(separatedBy: "M")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum += UInt64(sourceSize)!
        }else if sourceSize.contains("K") {
            sourceSize = sourceSize.components(separatedBy: "K")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum += UInt64(sourceSize)!
        }else if sourceSize.contains("B") {
            sourceSize = sourceSize.components(separatedBy: "B")[0]
            if sourceSize.contains(".") {
                sourceSize = sourceSize.components(separatedBy: ".")[0]
            }
            sourceSizeNum += UInt64(sourceSize)!
        }else{
            log(isError: true, "Analysis failed.")
            return "ERROR: Size unrecognized. Perhaps source is larger than a terabyte?"
        }
        
        log(isError: false, "Total reported source size: \(sourceSizeNum)")

        if sourceSizeUnit > destinationFreeUnit {
            return "NO"
        }else if sourceSizeUnit < destinationFreeUnit {
            return "OK"
        }else{
            if destinationFreeNum > sourceSizeNum * 2 {
                return "OK"
            }else{
                return "NO"
            }
        }
    }

    func copyApplications(destination: String) -> String {
        log(isError: false, "Copying apps...")
        NSSwiftUtils.createDirectoryWithParentsDirectories(to: destination.replacingOccurrences(of: ".dpz", with: "") + "/Apps")
        let returned = NSSwiftUtils.executeShellScript("rsync", "-qrl", "--safe-links", "/Applications/", destination.replacingOccurrences(of: ".dpz", with: "") + "/Apps")
        if returned == 0 || returned == 23 || returned == 1{
            return "OK"
        }else{
            return "ERROR:Data copy subprocess returned exit code \(returned). (Applications)"
        }
    }
    
    func copyUserData(source: String, destination: String) -> String {
        log(isError: false, "Making parents directory...")
        if !NSSwiftUtils.createDirectoryWithParentsDirectories(to: destination.replacingOccurrences(of: ".dpz", with: "")) {
            log(isError: true, "Failed creating backup destination directory.")
            return "ERROR:Failed creating backup destination directory."
        }
        log(isError: false, "Copying files...")
        let returned = NSSwiftUtils.executeShellScript("rsync", "-qrl", "--safe-links", "--exclude", "Library", "--exclude", ".*", source, destination.replacingOccurrences(of: ".dpz", with: ""))
        if returned == 0 {
            return "OK"
        }else{
            cleanUp(destination: destination)
            return "ERROR:Data copy subprocess returned exit code \(returned). (User Data)"
        }
    }
    
    func createDisk(destination: String, password: String) -> String {
        log(isError: false, "Creating as encrypted disk...")
        let returned = NSSwiftUtils.pipeCommandline(primaryCommand: "echo#-n#\(password)", execCommands: "hdiutil#create#-srcfolder#\(destination.replacingOccurrences(of: ".dpz", with: ""))#-format#UDRO#-encryption#-stdinpass#-volname#DataPackerBackup#\(destination)")
        if returned.exitcode == 0 {
            if NSSwiftUtils.doesTheFileExist(at: destination + ".dmg") {
                NSSwiftUtils.executeShellScript("mv", "\(destination).dmg", destination)
            }
            return "OK"
        }else{
            cleanUp(destination: destination)
            return "ERROR: Disk create subprocess returned exit code \(returned.exitcode)."
        }
    }
    
    func cleanUp(destination: String) {
        log(isError: false, "Removing copied files...")
        NSSwiftUtils.executeShellScript("rm", "-rf", destination.replacingOccurrences(of: ".dpz", with: ""))
    }
}
