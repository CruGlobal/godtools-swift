//
//  ZipFileContentsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SSZipArchive

protocol ZipFileContentsCacheType {
       
    var fileManager: FileManager { get }
    var errorDomain: String { get }
    
    func getUserDocumentsDirectory() -> Result<URL, Error>
    func getRootDirectory() -> Result<URL, Error>
    func getContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error>
    func deleteContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error>
    func createNewContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error>
    func cacheContents(location: ZipFileContentsCacheLocationType, zipData: Data) -> Result<URL, Error>
    func getData(url: URL) -> Data?
    func getContentsUrls(location: ZipFileContentsCacheLocationType) -> Result<[URL], Error>
    func getContentsPaths(location: ZipFileContentsCacheLocationType) -> Result<[String], Error>
    func contentsExist(location: ZipFileContentsCacheLocationType) -> Result<Bool, Error>
}

extension ZipFileContentsCacheType {
    
    func getUserDocumentsDirectory() -> Result<URL, Error> {
        
        do {
            let documentsDirectory: URL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return .success(documentsDirectory)
        }
        catch let error {
            return .failure(error)
        }
    }
    
    func getContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error> {
        
        guard let relativeUrl = location.relativeUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Relative url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(relativeUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error> {
        
        switch getContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            if fileManager.fileExists(atPath: contentsDirectory.path) {
                do {
                    try fileManager.removeItem(at: contentsDirectory)
                    return .success(contentsDirectory)
                }
                catch let removeItemError {
                    return .failure(removeItemError)
                }
            }
            return .success(contentsDirectory)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createNewContentsDirectory(location: ZipFileContentsCacheLocationType) -> Result<URL, Error> {
        
        switch deleteContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            do {
                try fileManager.createDirectory(
                    at: contentsDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return .success(contentsDirectory)
            }
            catch let error {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func cacheContents(location: ZipFileContentsCacheLocationType, zipData: Data) -> Result<URL, Error> {
        
        switch createNewContentsDirectory(location: location) {
       
        case .success(let contentsDirectory):
            
            let zipFile: URL = contentsDirectory.appendingPathComponent("contents.zip")
                        
            // create zip file inside contents directory
            if !fileManager.createFile(atPath: zipFile.path, contents: zipData, attributes: nil) {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create zip file at url: \(zipFile.absoluteString)"]))
            }
            
            // unzip contents of zipfile into contents directory
            if !SSZipArchive.unzipFile(atPath: zipFile.path, toDestination: contentsDirectory.path) {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip file at url: \(zipFile.absoluteString)"]))
            }
            
            // delete zipfile inside contents directory because contents were unzipped and it is no longer needed
            do {
                try fileManager.removeItem(at: zipFile)
            }
            catch let error {
                return .failure(error)
            }
            
            // check if the unzipped contents is a single directory and if it is, move contents of this directory up a level into the contents directory
            do {
                let contentsOfContentsDirectory: [String] = try fileManager.contentsOfDirectory(atPath: contentsDirectory.path)
                
                if contentsOfContentsDirectory.count == 1 {
                    
                    let itemUrl: URL = contentsDirectory.appendingPathComponent(contentsOfContentsDirectory[0])
                    
                    if isDirectory(url: itemUrl) {
                        
                        if let moveItemsError = moveContentsOfDirectory(directory: itemUrl, toDirectory: contentsDirectory) {
                            return .failure(moveItemsError)
                        }
                        
                        // delete directory since contents were moved
                        do {
                           try fileManager.removeItem(at: itemUrl)
                        }
                        catch let error {
                            return .failure(error)
                        }
                    }
                }// end moving contents of single directory up a level
            }
            catch let error {
                return .failure(error)
            }
            
            // finished with no errors, return url where contents are unzipped to
            return .success(contentsDirectory)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory){
            return isDirectory.boolValue
        }
        return false
    }
    
    private func moveContentsOfDirectory(directory: URL, toDirectory: URL) -> Error? {
        
        do {
            let contents: [String] = try fileManager.contentsOfDirectory(atPath: directory.path)
            for item in contents {
                do {
                    try fileManager.moveItem(atPath: directory.appendingPathComponent(item).path, toPath: toDirectory.appendingPathComponent(item).path)
                }
                catch let error {
                    return error
                }
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    func getData(url: URL) -> Data? {
        return fileManager.contents(atPath: url.path)
    }
    
    func getData(location: ZipFileContentsCacheLocationType, path: String) -> Result<Data?, Error> {
        
        switch getContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            return .success(getData(url: contentsDirectory.appendingPathComponent(path)))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getContentsUrls(location: ZipFileContentsCacheLocationType) -> Result<[URL], Error> {
        
        switch getContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            do {
                let contents: [URL] = try fileManager.contentsOfDirectory(at: contentsDirectory, includingPropertiesForKeys: nil, options: [])
                return .success(contents)
            }
            catch let error {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getContentsPaths(location: ZipFileContentsCacheLocationType) -> Result<[String], Error> {
        
        switch getContentsDirectory(location: location) {
        case .success(let contentsDirectory):
            do {
                let contents: [String] = try fileManager.contentsOfDirectory(atPath: contentsDirectory.path)
                return .success(contents)
            }
            catch let error {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func contentsExist(location: ZipFileContentsCacheLocationType) -> Result<Bool, Error> {
        
        switch getContentsDirectory(location: location) {
        case .success(let url):
            var contentsExist: Bool = false
            if fileManager.fileExists(atPath: url.path) {
                switch getContentsPaths(location: location) {
                case .success(let contents):
                    contentsExist = contents.count > 0
                case .failure(let error):
                    return .failure(error)
                }
            }
            return .success(contentsExist)
        case .failure(let error):
            return .failure(error)
        }
    }
}
