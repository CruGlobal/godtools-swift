//
//  FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class FileCache {
    
    let fileManager: FileManager
    let rootDirectory: String
    let errorDomain: String
    
    init(rootDirectory: String, fileManager: FileManager = FileManager.default) {
        
        self.fileManager = fileManager
        self.rootDirectory = rootDirectory
        self.errorDomain = "\(type(of: self))"
    }
    
    func getIsDirectory(url: URL) -> Bool {
        
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory){
            return isDirectory.boolValue
        }
        
        return false
    }
    
    func getUserDocumentsDirectory() throws -> URL {
        
        return try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    
    func getRootDirectory() throws -> URL {
    
        return try getUserDocumentsDirectory()
            .appendingPathComponent(rootDirectory)
    }
    
    func getDirectory(location: FileCacheLocation) throws -> URL {
                
        guard let directoryUrl = location.directoryUrl else {
            return try getRootDirectory()
        }
        
        return try getRootDirectory()
            .appendingPathComponent(directoryUrl.path)
    }
    
    private func createDirectoryIfNotExists(location: FileCacheLocation) throws -> URL {
        
        let directoryUrl = try getDirectory(location: location)
        
        return try createDirectoryIfNotExists(directoryUrl: directoryUrl)
    }
    
    func createDirectoryIfNotExists(directoryUrl: URL) throws -> URL {
        
        guard !fileManager.fileExists(atPath: directoryUrl.path) else {
            return directoryUrl
        }
        
        try fileManager.createDirectory(
            at: directoryUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return directoryUrl
    }
    
    func getFileExists(location: FileCacheLocation) throws -> Bool {
        
        let url = try getFile(location: location)
        
        return fileManager.fileExists(atPath: url.path)
    }
    
    func getFile(location: FileCacheLocation) throws -> URL {
        
        guard let fileUrl = location.fileUrl else {
            
            let error: Error = NSError.errorWithDescription(
                description: "Found nil fileUrl on FileCacheLocation with relativeUrlString: \(location.relativeUrlString)"
            )
            
            throw error
        }
        
        let rootDirectory = try getRootDirectory()
        
        return rootDirectory
            .appendingPathComponent(fileUrl.path)
    }
    
    func getData(location: FileCacheLocation) throws -> Data? {
        
        let url = try getFile(location: location)
        
        return fileManager.contents(atPath: url.path)
    }
    
    func getUIImage(location: FileCacheLocation) throws -> UIImage? {
        
        let data = try getData(location: location)
        
        guard let data = data else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    func getImage(location: FileCacheLocation) throws -> Image? {
        
        guard let uiImage = try getUIImage(location: location) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    func storeFile(location: FileCacheLocation, data: Data) throws -> URL {
        
        _ = try createDirectoryIfNotExists(location: location)
        
        let url = try getFile(location: location)
        
        if fileManager.createFile(atPath: url.path, contents: data, attributes: nil) {
            
            return url
        }
        else {
            
            let error: Error = NSError(
                domain: errorDomain,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create file at url: \(url.absoluteString)"]
            )
            
            throw error
        }
    }
    
    func removeRootDirectory() throws {
        
        let rootDirectoryUrl = try getRootDirectory()
        
        try removeItem(url: rootDirectoryUrl)
    }

    func removeFile(location: FileCacheLocation) throws {
        
        let fileUrl = try getFile(location: location)
        
        try removeItem(url: fileUrl)
    }
    
    func removeItem(url: URL) throws {
        
        try fileManager.removeItem(at: url)
    }
    
    func moveContentsOfDirectory(directory: URL, toDirectory: URL) throws {
        
        let contents: [String] = try fileManager.contentsOfDirectory(atPath: directory.path)
        
        for item in contents {
            
            try fileManager.moveItem(
                atPath: directory.appendingPathComponent(item).path,
                toPath: toDirectory.appendingPathComponent(item).path
            )
        }
    }
    
    func moveChildDirectoryContentsIntoParent(parentDirectory: URL) throws {
       
        // check if the contents is a single directory and if it is, move contents of this directory up a level into the parent directory
        
        let contentsOfParentDirectory: [String] = try fileManager.contentsOfDirectory(atPath: parentDirectory.path)
        
        guard contentsOfParentDirectory.count == 1 else {
            return
        }
        
        let childDirectory: URL = parentDirectory.appendingPathComponent(contentsOfParentDirectory[0])
        
        guard getIsDirectory(url: childDirectory) else {
            return
        }
        
        try moveContentsOfDirectory(directory: childDirectory, toDirectory: parentDirectory)
        
        // delete directory since contents were moved
        try fileManager.removeItem(at: childDirectory)
    }
}
