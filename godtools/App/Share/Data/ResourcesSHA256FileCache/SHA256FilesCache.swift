//
//  SHA256FilesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SSZipArchive

@available(*, deprecated) // This should be removed in place of ResourcesSHA256FileCache now pointing to a FileCache following work in GT-1448. ~Levi
class SHA256FilesCache {
    
    private let fileManager: FileManager = FileManager.default
    private let rootDirectory: String
    private let errorDomain: String
    
    required init(rootDirectory: String) {
        
        self.rootDirectory = rootDirectory
        self.errorDomain = "\(type(of: self))"
        
        switch createRootDirectoryIfNotExists() {
        case .success( _):
            break
        case .failure(let error):
            assertionFailure("\(errorDomain): Failed to create root directory: \(rootDirectory) with error: \(error)")
        }
    }
    
    private func getUserDocumentsDirectory() -> Result<URL, Error> {
        
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
    
    private func getRootDirectory() -> Result<URL, Error> {
    
        switch getUserDocumentsDirectory() {
        case .success(let documentsDirectory):
            return .success(documentsDirectory.appendingPathComponent(rootDirectory))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getContentsOfRootDirectory() -> Result<[String], Error> {
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            do {
                let contents: [String] = try fileManager.contentsOfDirectory(atPath: rootDirectory.path)
                return .success(contents)
            }
            catch let error{
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createRootDirectoryIfNotExists() -> Result<URL, Error> {
        
        switch getRootDirectory() {
        
        case .success(let rootDirectoryUrl):
            return createDirectoryIfNotExists(directoryUrl: rootDirectoryUrl)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func createDirectoryIfNotExists(directoryUrl: URL) -> Result<URL, Error> {
        
        if !fileManager.fileExists(atPath: directoryUrl.path) {
            
            do {
                try fileManager.createDirectory(
                    at: directoryUrl,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return .success(directoryUrl)
            }
            catch let error {
                return .failure(error)
            }
        }
        else {
            return .success(directoryUrl)
        }
    }
    
    func getFile(location: SHA256FileLocation) -> Result<URL, Error> {
        
        guard let fileUrl = location.fileUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "File url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(fileUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fileExists(location: SHA256FileLocation) -> Result<Bool, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.fileExists(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getData(location: SHA256FileLocation) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getImage(location: SHA256FileLocation) -> Result<UIImage?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            if let data = fileManager.contents(atPath: url.path) {
                return .success(UIImage(data: data))
            }
            return .success(nil)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func decompressZipFileAndCacheSHA256FileContents(zipData: Data) -> Result<[SHA256FileLocation], Error> {
        
        switch getRootDirectory() {
        
         case .success(let rootDirectory):
             
            let tempDirectoryName: String = "temp_directory_" + UUID().uuidString
            let contentsTempDirectory: URL = rootDirectory.appendingPathComponent(tempDirectoryName)
            
            var cachedSHA256FileLocations: [SHA256FileLocation] = Array()
            
            switch createDirectoryIfNotExists(directoryUrl: contentsTempDirectory) {
            case .success( _):
                break
            case .failure(let error):
                return .failure(error)
            }
            
            let zipFile: URL = contentsTempDirectory.appendingPathComponent("contents.zip")
                                                 
            // create zip file inside contents temp directory
            if !fileManager.createFile(atPath: zipFile.path, contents: zipData, attributes: nil) {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create zip file at url: \(zipFile.absoluteString)"]))
            }
             
            // unzip contents of zipfile into contents temp directory
            if !SSZipArchive.unzipFile(atPath: zipFile.path, toDestination: contentsTempDirectory.path) {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip file at url: \(zipFile.absoluteString)"]))
            }
            
            // delete zipfile inside contents directory because contents were unzipped and it is no longer needed
            do {
                try fileManager.removeItem(at: zipFile)
            }
            catch let error {
                return .failure(error)
            }
            
            // check if unzipped contents contains single directory and move those items up
            let moveError: Error? = moveChildDirectoryContentsIntoParentDirectoryIfNeeded(parentDirectory: contentsTempDirectory)
            if let moveError = moveError {
                return .failure(moveError)
            }
            
            // get zipfile contents
            let zipFileContents: [URL]
            
            do {
                let contents: [String] = try fileManager.contentsOfDirectory(atPath: contentsTempDirectory.path)
                zipFileContents = contents.compactMap({URL(string: $0)})
            }
            catch let error {
                return .failure(error)
            }
            
            guard !zipFileContents.isEmpty else {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unzip contents because no files exist."]))
            }
            
            for fileUrl in zipFileContents {
                
                let tempFileUrl: URL = contentsTempDirectory.appendingPathComponent(fileUrl.path)
                
                if let data = fileManager.contents(atPath: tempFileUrl.path) {
                    
                    let path: String = fileUrl.path
                    let pathExtension: String = fileUrl.pathExtension
                    
                    let sha256: String
                    if !pathExtension.isEmpty {
                        sha256 = path.replacingOccurrences(of: "." + pathExtension, with: "")
                    }
                    else {
                        sha256 = path
                    }
                    
                    let location = SHA256FileLocation(sha256: sha256, pathExtension: pathExtension)
                    let cacheError: Error? = cacheSHA256File(location: location, fileData: data)
                                        
                    if let cacheError = cacheError {
                        return .failure(cacheError)
                    }
                    else {
                        cachedSHA256FileLocations.append(location)
                    }
                }
                else {
                    //return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed, file data does not exist."]))
                }
            }
            
            // delete zipFile temp directory
            do {
                try fileManager.removeItem(at: contentsTempDirectory)
            }
            catch let error {
                return .failure(error)
            }
            
            // finished with no errors
            return .success(cachedSHA256FileLocations)
             
         case .failure(let error):
            return .failure(error)
         }
    }
    
    func cacheSHA256FileIfNotExists(location: SHA256FileLocation, fileData: Data) -> Error? {
        
        var fileExistsInCache: Bool = false
        
        switch fileExists(location: location) {
        case .success(let fileExists):
            fileExistsInCache = fileExists
        case .failure(let error):
            return error
        }
        
        if !fileExistsInCache {
            return cacheSHA256File(location: location, fileData: fileData)
        }
        else {
            return nil
        }
    }
    
    func cacheSHA256File(location: SHA256FileLocation, fileData: Data) -> Error? {
        
        switch getFile(location: location) {
        case .success(let url):
            if fileManager.createFile(atPath: url.path, contents: fileData, attributes: nil) {
                return nil
            }
            else {
                return NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create file at url: \(url.absoluteString)"])
            }
        case.failure(let error):
            return error
        }
    }
    
    func removeFile(location: SHA256FileLocation) -> Error? {
        
        switch getFile(location: location) {
        case .success(let fileUrl):
            return removeItem(url: fileUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeItem(url: URL) -> Error? {
        
        do {
            try fileManager.removeItem(at: url)
            return nil
        }
        catch let error {
            return error
        }
    }
    
    private func moveChildDirectoryContentsIntoParentDirectoryIfNeeded(parentDirectory: URL) -> Error? {
       
        // check if the unzipped contents is a single directory and if it is, move contents of this directory up a level into the contents directory
        do {
            let contentsOfParentDirectory: [String] = try fileManager.contentsOfDirectory(atPath: parentDirectory.path)
            
            if contentsOfParentDirectory.count == 1 {
                
                let childDirectory: URL = parentDirectory.appendingPathComponent(contentsOfParentDirectory[0])
                
                if isDirectory(url: childDirectory) {
                    
                    if let moveItemsError = moveContentsOfDirectory(directory: childDirectory, toDirectory: parentDirectory) {
                        return moveItemsError
                    }
                    
                    // delete directory since contents were moved
                    do {
                       try fileManager.removeItem(at: childDirectory)
                    }
                    catch let error {
                        return error
                    }
                }
            }// end moving contents of single directory up a level
        }
        catch let error {
            return error
        }
        
        return nil
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
}
