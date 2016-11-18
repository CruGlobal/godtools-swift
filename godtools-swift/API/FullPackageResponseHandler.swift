//
//  FullPackageResponseHandler.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/31/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import Zip
import SWXMLHash
import CoreData
import PromiseKit

class FullPackageResponseHandler: NSObject {
    
    func extractAndProcessFileAt(location :URL?, language :GodToolsLanguage) {
        if (location == nil) {
            return;
        }
        
        do {
            let unzipDirectory = try Zip.quickUnzipFile(location!)
            let destinationDirectory = createGTFilesDirectoryIfNecessary()
            
            updateLocalFromContents(location: unzipDirectory, forLanguage: language)
            moveDownloadedAssetsToGTFiles(source: unzipDirectory, destination: destinationDirectory)
            
            try FileManager.default.removeItem(at: unzipDirectory)
            try FileManager.default.removeItem(at: location!)
        } catch {
            
        }
    }
    
    func createGTFilesDirectoryIfNecessary () -> URL {
        let fileManager = FileManager.default
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectoryFileURL = URL.init(fileURLWithPath: paths[0])
        
        let GTFilesDirectoryFileURL = documentsDirectoryFileURL.appendingPathComponent("Packages")
        
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
    
    func updateLocalFromContents (location :URL, forLanguage :GodToolsLanguage) {
        do {
            let xmlFile :Data = try Data(contentsOf: location.appendingPathComponent("contents.xml"))
            let context = GodToolsPersistence.context()
            
            SWXMLHash.parse(xmlFile)["content"]["resource"].forEach({ (xmlResource) in
                let code = xmlResource.element?.attribute(by: "package")?.text
                
                let packages = GodToolsPackage.fetchBy(code: code!, languageCode: forLanguage.code!, context: context)
                var package = packages?[0]
                
                if (packages != nil && packages?.count == 1) {
                    package = packages![0]
                } else {
                    package = NSEntityDescription.insertNewObject(forEntityName: "GodToolsPackage", into: context) as? GodToolsPackage
                    forLanguage.addToPackages(package!)
                }
                
                let version = xmlResource.element?.attribute(by: "version")?.text
                
                package!.code = code!
                package!.name = xmlResource.element?.attribute(by: "name")?.text
                package!.status = xmlResource.element?.attribute(by: "status")?.text
                package!.majorVersion = Int16(version!.components(separatedBy: ".")[0])!
                package!.minorVersion = Int16(version!.components(separatedBy: ".")[1])!
                package!.iconFilename = xmlResource.element?.attribute(by: "icon")?.text
                package!.configFilename = xmlResource.element?.attribute(by: "config")?.text
            })
            try context.save()
        } catch {
            
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
