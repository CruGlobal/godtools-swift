//
//  FileCache+SSZipArchive.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import ZipArchive
import Combine

extension FileCache {
    
    func decompressZipFileAndStoreFileContents(zipFileData: Data) throws -> [FileCacheLocation] {
        
        let rootDirectory = try getRootDirectory()
        
        return try decompressZipFileAndStoreFileContentsAtDirectory(
            directory: rootDirectory,
            zipFileData: zipFileData
        )
    }
    
    func decompressZipFileAndStoreFileContentsAtDirectory(directory: URL, zipFileData: Data) throws -> [FileCacheLocation] {
        
        let contentsTempDirectory: URL = directory.appendingPathComponent("temp_directory_" + UUID().uuidString)
                
        _ = try createDirectoryIfNotExists(directoryUrl: contentsTempDirectory)
        
        let zipFile: URL = contentsTempDirectory.appendingPathComponent("contents.zip")
                                             
        // create zip file inside contents temp directory
        if !fileManager.createFile(atPath: zipFile.path, contents: zipFileData, attributes: nil) {
            
            let error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create zip file at url: \(zipFile.absoluteString)"]
            )
            
            throw error
        }
         
        // unzip contents of zipfile into contents temp directory
        if !SSZipArchive.unzipFile(atPath: zipFile.path, toDestination: contentsTempDirectory.path) {
        
            let error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to unzip file at url: \(zipFile.absoluteString)"]
            )
            
            throw error
        }
        
        // delete zipfile inside contents directory because contents were unzipped and it is no longer needed
        try fileManager.removeItem(at: zipFile)
        
        // check if unzipped contents contains single directory and move those items up
        try moveChildDirectoryContentsIntoParent(parentDirectory: contentsTempDirectory)
        
        // get zipfile contents
        let zipFileContents: [URL]
        
        let contents: [String] = try fileManager.contentsOfDirectory(atPath: contentsTempDirectory.path)
        zipFileContents = contents.compactMap({URL(string: $0)})
        
        guard !zipFileContents.isEmpty else {
            
            let error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to unzip contents because no files exist."]
            )
            
            throw error
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
            
            _ = try storeFile(location: location, data: data)
            
            storedFileLocations.append(location)
        }
        
        // delete zipFile temp directory
        try fileManager.removeItem(at: contentsTempDirectory)
        
        return storedFileLocations
    }
}
