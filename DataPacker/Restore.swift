//
//  Restore.swift
//  DataPacker
//
//  Created by Hoyoun Song on 2020/08/07.
//

import Foundation
import Cocoa
public class Restore {
    @IBOutlet var LogView: NSTextView!
    
    let mountpoint = "/tmp/dprestore"
    
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
    
    func queryFreeSpace(destination: String) -> String {
        var destinationFreeUnit: UInt8
        var destinationFreeNum: UInt64
        
        var sourceSizeUnit: UInt8
        var sourceSizeNum: UInt64
        
        log(isError: false, "Asking shell for free space...")
        var destinationFree = NSSwiftUtils.runCommand("df" ,"-h", destination).output[1].replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").components(separatedBy: " ")[3]
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
        
        log(isError: false, "Asking shell for source size...")
        var sourceSize = NSSwiftUtils.runCommand("du" ,"-ch", mountpoint).output.last!.components(separatedBy: " ")[1].components(separatedBy: "/")[0].replacingOccurrences(of: " ", with: "")
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
        
        log(isError: false, "Total reported source size: \(sourceSizeNum)")

        if sourceSizeUnit > destinationFreeUnit {
            return "NO"
        }else if sourceSizeUnit < destinationFreeUnit {
            return "OK"
        }else{
            if Double(destinationFreeNum) > Double(sourceSizeNum) * 1.5 {
                return "OK"
            }else{
                return "NO"
            }
        }
    }
    
    func decryptBackup(source: String, password: String) -> String {
        log(isError: false, "Creating mount point...")
        NSSwiftUtils.createDirectoryWithParentsDirectories(to: mountpoint)
        log(isError: false, "Mounting backup disk...")
        let output = NSSwiftUtils.pipeCommandline(primaryCommand: "echo#-n#\(password)", execCommands: "hdiutil#attach#-stdinpass#\(source)#-mountpoint#\(mountpoint)").error
        if output.elementsEqual("") {
            if NSSwiftUtils.doesTheFileExist(at: mountpoint + "/Documents") {
                return "OK"
            }else{
                return "ERROR:Unable to find backup data."
            }
        }else{
            if output.contains("Authentication error") {
                return "ERROR:Password does not match."
            }else{
                return "ERROR:\(output.replacingOccurrences(of: "hdiutil: attach failed - ", with: ""))"
            }
        }
    }
    
    func copy(destination: String) -> String {
        NSSwiftUtils.executeShellScript("rsync", "-qrl", "--exclude", "info.dp", mountpoint + "/", destination + "/")
        return "OK"
    }
    
    func cleanUp() {
        log(isError: false, "Detaching restore disk...")
        NSSwiftUtils.executeShellScript("hdiutil", "detach", mountpoint, "-force")
    }
}
