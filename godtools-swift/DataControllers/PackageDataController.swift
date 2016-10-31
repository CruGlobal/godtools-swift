//
//  PackageDataController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/26/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Zip

class PackageDataController: NSObject {
    
    func updateFromRemote() {
        var code = GodToolsSettings.init().primaryLanguage()
        
        if (code == nil) {
            code = "en"
        }
        
        GodtoolsAPI.sharedInstance.getPackages(forLanguage: code!).then { fileURL -> Void in
            if (fileURL == nil) {
                return;
            }
            
            do {
                let unzipDirectory = try Zip.quickUnzipFile(fileURL!)
                let destinationDirectory = self.createGTFilesDirectoryIfNecessary()
                
                self.moveDownloadedAssetsToGTFiles(source: unzipDirectory, destination: destinationDirectory)
                try FileManager.default.removeItem(at: unzipDirectory)
                try FileManager.default.removeItem(at: fileURL!)
            }
            
        }.catch { (error) in
            debugPrint(error)
        }
    }
    
    func createGTFilesDirectoryIfNecessary () -> URL {
        let fileManager = FileManager.default
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectoryFileURL = URL.init(fileURLWithPath: paths[0])
        
        let GTFilesDirectoryFileURL = documentsDirectoryFileURL.appendingPathComponent("GTFiles")
        
        if (fileExists(file: GTFilesDirectoryFileURL)) {
            return GTFilesDirectoryFileURL
        }
        
        do {
            try fileManager.createDirectory(at: GTFilesDirectoryFileURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        return GTFilesDirectoryFileURL
    }
    
    func moveDownloadedAssetsToGTFiles (source :URL, destination :URL) {
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(at: source, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            
            try files.forEach({ (file) in
                let destinationFullPath = destination.appendingPathComponent(file.lastPathComponent)
                
                if (file.lastPathComponent == "contents.xml") {
                    return
                }
                
                if (fileExists(file: destinationFullPath)) {
                    return
                }
                
                try fileManager.copyItem(at: file, to: destinationFullPath)
            })
        } catch {
            debugPrint(error)
        }
    }
    
    func fileExists (file: URL) -> Bool {
        do {
            return try file.checkResourceIsReachable()
        } catch {
            // URL.checkResourceIsReachable() inexplicably and seemingly returns 'true' if a file exists and throws an error if it does not.
            return false
        }
    }    
}
