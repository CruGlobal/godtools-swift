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

class FullPackageResponseHandler: NSObject {
    
    func extractAndProcessFileAt(location :URL?, languageCode :String) {
        
        if (location == nil) {
            return;
        }
        
        do {
            let unzipDirectory = try Zip.quickUnzipFile(location!)
            let destinationDirectory = createGTFilesDirectoryIfNecessary()
            let language = loadLanguage(languageCode: languageCode)
            
            if (language == nil) {
                //....
            }
            
            updateLocalFromContents(location: unzipDirectory, forLanguage: language!)
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
    
    func loadLanguage (languageCode :String) -> GodToolsLanguage? {
        let languageFetchRequest :NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()
        languageFetchRequest.predicate = NSPredicate(format: "code = %@", languageCode)
        
        do {
            let languages = try GodToolsPersistence.context().fetch(languageFetchRequest)
            
            if (languages.count > 0) {
                return languages[0]
            }
        } catch {
            
        }
        return nil
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
            
            try SWXMLHash.parse(xmlFile)["content"]["resource"].forEach({ (xmlResource) in
                let name = xmlResource.element?.attribute(by: "name")?.text
                let code = xmlResource.element?.attribute(by: "package")?.text
                let status = xmlResource.element?.attribute(by: "status")?.text
                let version = xmlResource.element?.attribute(by: "version")?.text
                
                let packageFetchRequest :NSFetchRequest<GodToolsPackage> = GodToolsPackage.fetchRequest()
                packageFetchRequest.predicate = NSPredicate(format: "code = %@ AND language.code = %@", code!, forLanguage.code!)
                
                let packages = try context.fetch(packageFetchRequest)
                
                if (packages.count == 1) {
                    packages[0].name = name!
                } else {
                    let newPackage = NSEntityDescription.insertNewObject(forEntityName: "GodToolsPackage", into: context) as! GodToolsPackage
                    newPackage.code = code!
                    newPackage.name = name!
                    forLanguage.addToPackages(newPackage)
                }
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
