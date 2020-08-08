//
//  ViewController.swift
//  DataPacker
//
//  Created by Hoyoun Song on 2020/08/07.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var LogView: NSTextView!
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var ProgressLabel: NSTextField!
    @IBOutlet weak var ActionSelector: NSSegmentedControl!
    @IBOutlet weak var SourceTextField: NSTextField!
    @IBOutlet weak var DestinationTextField: NSTextField!
    @IBOutlet weak var PasswordTextField: NSSecureTextField!
    @IBOutlet weak var Button_SelectSource: NSButton!
    @IBOutlet weak var Button_SelectDestination: NSButton!
    @IBOutlet weak var Wheel: NSProgressIndicator!
    
    var selectedAction: Int = -1
    
    let Version = "1.0"
    
    let Graphics: GraphicComponents = GraphicComponents()
    
    @IBAction func SelectSource(_ sender: Any) {
        if selectedAction == 0 {
            // For backup
            let sourcePath = Graphics.selectFile(canChooseDirectories: true, canChooseFiles: false, showsResizeIndicator: false, showsHiddenFiles: false, allowMultipleSelections: false, title: "Choose directory to backup.")
            if sourcePath.elementsEqual("") {
                Graphics.messageBox_errorMessage(title: "Invalid Directory Selection", contents: "Source is not selected correctly.")
            }else{
                log(isError: false, "Source selected: \(sourcePath)")
                SourceTextField.stringValue = sourcePath
            }
        }else{
            // For restore
            let sourcePath = Graphics.selectFile(canChooseDirectories: false, canChooseFiles: true, showsResizeIndicator: false, showsHiddenFiles: false, allowMultipleSelections: false, title: "Choose file to restore.")
            if sourcePath.elementsEqual("") || !sourcePath.hasSuffix(".dpz") {
                Graphics.messageBox_errorMessage(title: "Invalid Backup Selection", contents: "Source is not selected correctly.")
            }else{
                log(isError: false, "Source selected: \(sourcePath)")
                SourceTextField.stringValue = sourcePath
            }
        }
    }
    
    @IBAction func SelectDestination(_ sender: Any) {
        if selectedAction == 0 {
            // For backup
            let destPath = Graphics.selectFile(canChooseDirectories: true, canChooseFiles: false, showsResizeIndicator: false, showsHiddenFiles: false, allowMultipleSelections: false, title: "Choose location to store backup to.")
            if destPath.elementsEqual("") {
                Graphics.messageBox_errorMessage(title: "Invalid Directory Selection", contents: "Destination is not selected correctly.")
            }else{
                log(isError: false, "Destination selected: \(destPath)/dpbackup.dpz")
                DestinationTextField.stringValue = destPath + "/dpbackup.dpz"
            }
        }else{
            // For restore
            let destPath = Graphics.selectFile(canChooseDirectories: true, canChooseFiles: false, showsResizeIndicator: false, showsHiddenFiles: false, allowMultipleSelections: false, title: "Choose location to restore.")
            if destPath.elementsEqual("") {
                Graphics.messageBox_errorMessage(title: "Invalid Directory Selection", contents: "Destination is not selected correctly.")
            }else{
                log(isError: false, "Destination selected: \(destPath)")
                DestinationTextField.stringValue = destPath
            }
        }
    }
    
    @IBAction func SelectAction(_ sender: Any) {
        switch ActionSelector.selectedSegment {
        case 0:
            log(isError: false, "Action selected: Backup")
            selectedAction = 0
            SourceTextField.stringValue = NSSwiftUtils.getHomeDirectory()
            SourceTextField.isEditable = false
            Button_SelectSource.isEnabled = false
        case 1:
            log(isError: false, "Action selected: Restore")
            selectedAction = 1
            SourceTextField.stringValue = ""
            SourceTextField.isEditable = true
            Button_SelectSource.isEnabled = true
            DestinationTextField.stringValue = NSSwiftUtils.getHomeDirectory()
        case 2:
            log(isError: false, "Action selected: Start Backup")
            programStart()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProgressBar.doubleValue = 0.0
        ProgressBar.maxValue = 100.0
        
        selectedAction = ActionSelector.indexOfSelectedItem
        SourceTextField.stringValue = NSSwiftUtils.getHomeDirectory()
        SourceTextField.isEditable = false
        Button_SelectSource.isEnabled = false
        
        Wheel.isHidden = true
        
        LogView.string += "\n[*] DataPacker \(Version)\n[*] Written by: 410-dev\n[*] Copyright (C) 410 2020. All rights reserved.\n"
        ProgressLabel.stringValue = ""
        LogView.string += "[*] View load complete. Program is now ready to go.\n"
    }

    override var representedObject: Any? {
        didSet {}
    }

    func log(isError: Bool, _ toLog: String){
        if isError {
            print("[-] \(toLog)")
            LogView.string += "[-] \(toLog)\n"
        }else{
            print("[*] \(toLog)")
            LogView.string += "[*] \(toLog)\n"
        }
        LogView.scrollToEndOfDocument(nil)
    }
    
    func programStart() {
        if SourceTextField.stringValue.count == 0 || DestinationTextField.stringValue.count == 0 || PasswordTextField.stringValue.count == 0 {
            Graphics.messageBox_errorMessage(title: "Fields Empty", contents: "Source, destination, or password field is empty. Please fill them out first, and try again.")
            log(isError: true, "Field data is empty.")
            log(isError: true, "Source: \(SourceTextField.stringValue)")
            log(isError: true, "Destination: \(DestinationTextField.stringValue)")
            log(isError: true, "Password Length: \(PasswordTextField.stringValue.count)")
        }else if NSSwiftUtils.isFile(at: SourceTextField.stringValue) && selectedAction == 0 {
            Graphics.messageBox_errorMessage(title: "Invalid Selection", contents: "Source should be a directory if selected action is backup.")
            log(isError: true, "Invalid selection: Expected directory, but input locates a file.")
        }else if !NSSwiftUtils.isFile(at: SourceTextField.stringValue) && selectedAction == 1 {
            Graphics.messageBox_errorMessage(title: "Invalid Selection", contents: "Source should be a backup file if selected action is restore.")
            log(isError: true, "Invalid selection: Expected a file, but input locates a directory.")
        }else if NSSwiftUtils.isFile(at: DestinationTextField.stringValue) {
            Graphics.messageBox_errorMessage(title: "Invalid Selection", contents: "Destination should be a directory.")
            log(isError: true, "Invalid selection: Expected directory, but input locates a file.")
        }else if !NSSwiftUtils.doesTheFileExist(at: SourceTextField.stringValue) || !NSSwiftUtils.doesTheFileExist(at: DestinationTextField.stringValue.replacingOccurrences(of: "/dpbackup.dpz", with: "")) {
            Graphics.messageBox_errorMessage(title: "No Such File", contents: "Unable to find such source or destination.")
            log(isError: true, "Invalid navigation.")
        }else{
            SourceTextField.isEnabled = false
            DestinationTextField.isEnabled = false
            PasswordTextField.isEnabled = false
            Button_SelectSource.isEnabled = false
            Button_SelectDestination.isEnabled = false
            ActionSelector.isEnabled = false
            ProgressBar.doubleValue = 0
            log(isError: false, "The app may seem unresponsive, but the app is still functional in the background. The process may take up to maximum several hours. Please do not quit the application.")
            Graphics.messageBox_dialogue(title: "Do not quit", contents: "The app may seem unresponsive, but the app is still functional in the background. The process may take up to maximum several hours. Please do not quit the application.")
            Wheel.isHidden = false
            Wheel.startAnimation(nil)
            PasswordTextField.stringValue = NSSwiftUtils.pipeCommandline(primaryCommand: "echo#\(PasswordTextField.stringValue)0fx0010110dpsalt!341116", execCommands: "shasum#-a#512").output.components(separatedBy: " ")[0]
            
            if selectedAction == 0 {
                log(isError: false, "Start action - Backup")
                let backup: Backup = Backup()
                backup.setup(view: LogView)
                
                let currentUNIXTimeStamp = UInt64(Date().timeIntervalSince1970)
                
                updateStatus(status: "Querying free space")
                var output = backup.queryStorage(source: SourceTextField.stringValue, destination: DestinationTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Query failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Query failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }else if output.elementsEqual("NO") {
                    log(isError: true, "Destination has insufficient space")
                    Graphics.messageBox_errorMessage(title: "Insufficient Space", contents: "Unable to run backup. The free space of the destination should be the twice of the source size. Query reported that the destination free space is less that required.")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 10
                
                
                updateStatus(status: "Copying User Files")
                output = backup.copyUserData(source: SourceTextField.stringValue, destination: DestinationTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Copy failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Copy failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 30
                
                
                updateStatus(status: "Copying Applications")
                output = backup.copyApplications(destination: DestinationTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Copy failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Copy failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 60
                
                
                updateStatus(status: "Packing Files")
                output = backup.createDisk(destination: DestinationTextField.stringValue, password: PasswordTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Packing failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Packing failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 95
                
                
                updateStatus(status: "Clean Up")
                backup.cleanUp(destination: DestinationTextField.stringValue)
                ProgressBar.doubleValue = 100
                
                processEnd(currentUNIXTimeStamp)
                Graphics.messageBox_dialogue(title: "Done", contents: "Backup process is completed.")
            }else{
                log(isError: false, "Start action - Restore")
                let restore: Restore = Restore()
                restore.setup(view: LogView)
                
                let currentUNIXTimeStamp = UInt64(Date().timeIntervalSince1970)
                
                updateStatus(status: "Decrypting Backup")
                var output = restore.decryptBackup(source: SourceTextField.stringValue, password: PasswordTextField.stringValue)
                if output.starts(with: "ERROR:") {
                    log(isError: true, "Decrypting failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Decrypting failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 20
                
                updateStatus(status: "Querying Free Space")
                output = restore.queryFreeSpace(destination: DestinationTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Query failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Query failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }else if output.elementsEqual("NO") {
                    log(isError: true, "Destination has insufficient space")
                    Graphics.messageBox_errorMessage(title: "Insufficient Space", contents: "Unable to run restore. The free space of the destination should be the twice of the source size. Query reported that the destination free space is less that required.")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 30
                
                updateStatus(status: "Restoring Files")
                output = restore.copy(destination: DestinationTextField.stringValue)
                if output.hasPrefix("ERROR:") {
                    log(isError: true, "Copy failed: \(output.components(separatedBy: ":")[1])")
                    Graphics.messageBox_errorMessage(title: "Error", contents: "Copy failed: \(output.components(separatedBy: ":")[1])")
                    processEnd(currentUNIXTimeStamp)
                    return
                }
                ProgressBar.doubleValue = 90
                
                updateStatus(status: "Clean Up")
                restore.cleanUp()
                ProgressBar.doubleValue = 100
                
                processEnd(currentUNIXTimeStamp)
                let Graphics: GraphicComponents = GraphicComponents()
                Graphics.messageBox_dialogue(title: "Restore Complete", contents: "Restore complete. Some applications have potential to conflict with current system, therefore it is moved to \(DestinationTextField.stringValue)/Apps. You can selectively copy the applications you need. Apps installed with package installer may not function properly.")
            }
        }
    }
    
    func processEnd(_ StartTime: UInt64) {
        log(isError: false, "Time took: \(UInt64(Date().timeIntervalSince1970) - StartTime) seconds")
        DestinationTextField.isEnabled = true
        PasswordTextField.isEnabled = true
        Button_SelectDestination.isEnabled = true
        ActionSelector.isEnabled = true
        Wheel.isHidden = true
        ProgressLabel.stringValue = ""
        if selectedAction == 0 {
            SourceTextField.stringValue = NSSwiftUtils.getHomeDirectory()
            SourceTextField.isEditable = false
            Button_SelectSource.isEnabled = false
        }else{
            SourceTextField.stringValue = ""
            SourceTextField.isEditable = true
            Button_SelectSource.isEnabled = true
        }
    }
    
    func updateStatus(status: String) {
        log(isError: false, "Current Process: \(status)")
        ProgressLabel.stringValue = status
    }
    
}
