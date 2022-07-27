//
//  FileCache+SSZipArchive.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SSZipArchive
import Combine

extension FileCache {
    
    func decompressZipFileAndStoreFileContents(zipFileData: Data) -> Result<[FileCacheLocation], Error> {
        
        switch getRootDirectory() {
        
        case .success(let rootDirectory):
            return decompressZipFileAndStoreFileContentsAtDirectory(directory: rootDirectory, zipFileData: zipFileData)
        
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func decompressZipFileAndStoreFileContentsPublisher(zipFileData: Data) -> AnyPublisher<[FileCacheLocation], Error> {
        
        switch decompressZipFileAndStoreFileContents(zipFileData: zipFileData) {
        
        case .success(let fileCacheLocations):
            return Just(fileCacheLocations).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func decompressZipFileAndStoreFileContentsAtDirectory(directory: URL, zipFileData: Data) -> Result<[FileCacheLocation], Error> {
        
        let contentsTempDirectory: URL = directory.appendingPathComponent("temp_directory_" + UUID().uuidString)
                
        switch createDirectoryIfNotExists(directoryUrl: contentsTempDirectory) {
        case .success( _):
            break
        case .failure(let error):
            return .failure(error)
        }
        
        let zipFile: URL = contentsTempDirectory.appendingPathComponent("contents.zip")
                                             
        // create zip file inside contents temp directory
        if !fileManager.createFile(atPath: zipFile.path, contents: zipFileData, attributes: nil) {
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
        let moveError: Error? = moveChildDirectoryContentsIntoParent(parentDirectory: contentsTempDirectory)
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
        
        var storedFileLocations: [FileCacheLocation] = Array()
        
        for fileUrl in zipFileContents {
            
            let tempFileUrl: URL = contentsTempDirectory.appendingPathComponent(fileUrl.path)
            
            guard let data = fileManager.contents(atPath: tempFileUrl.path) else {
                continue
            }
            
            // TODO: Is this path relative to the file cache? ~Levi
            let relativeUrlString: String = fileUrl.path
            
            let location: FileCacheLocation = FileCacheLocation(relativeUrlString: relativeUrlString)
                    
            
            switch storeFile(location: location, data: data) {
            case .success( _):
                storedFileLocations.append(location)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // delete zipFile temp directory
        do {
            try fileManager.removeItem(at: contentsTempDirectory)
        }
        catch let error {
            return .failure(error)
        }
        
        return .success(storedFileLocations)
    }
}
