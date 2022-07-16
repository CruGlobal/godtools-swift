//
//  FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FileCache<CacheLocation: FileCacheLocationType> {
    
    let fileManager: FileManager = FileManager.default
    let rootDirectory: String
    let errorDomain: String
    
    required init(rootDirectory: String) {
        self.rootDirectory = rootDirectory
        self.errorDomain = "\(type(of: self))"
    }
    
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
    
    func getRootDirectory() -> Result<URL, Error> {
    
        switch getUserDocumentsDirectory() {
        case .success(let documentsDirectory):
            return .success(documentsDirectory.appendingPathComponent(rootDirectory))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getDirectory(location: CacheLocation) -> Result<URL, Error> {
        
        guard let directoryUrl = location.directoryUrl else {
            return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Directory url can't be null."]))
        }
        
        switch getRootDirectory() {
        case .success(let rootDirectory):
            return .success(rootDirectory.appendingPathComponent(directoryUrl.path))
        case .failure(let error):
            return .failure(error)
        }
    }

    func getFile(location: CacheLocation) -> Result<URL, Error> {
        
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
    
    private func createDirectoryIfNotExists(location: CacheLocation) -> Result<URL, Error> {
        
        switch getDirectory(location: location) {
        
        case .success(let directoryUrl):
            
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
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func cache(location: CacheLocation, data: Data) -> Result<URL, Error> {
        
        switch createDirectoryIfNotExists(location: location) {
        case .success( _):
            break
        case .failure(let error):
            return .failure(error)
        }
        
        switch getFile(location: location) {
        case .success(let url):
            if fileManager.createFile(atPath: url.path, contents: data, attributes: nil) {
                return .success(url)
            }
            else {
                return .failure(NSError(domain: errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create file at url: \(url.absoluteString)"]))
            }
        case.failure(let error):
            return .failure(error)
        }
    }
    
    func getData(location: CacheLocation) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fileExists(location: CacheLocation) -> Result<Bool, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.fileExists(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func removeRootDirectory() -> Error? {
        
        switch getRootDirectory() {
        case .success(let rootDirectoryUrl):
            return removeItem(url: rootDirectoryUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeDirectory(location: CacheLocation) -> Error? {
        
        switch getDirectory(location: location) {
        case .success(let directoryUrl):
            return removeItem(url: directoryUrl)
        case .failure(let error):
            return error
        }
    }
    
    func removeFile(location: CacheLocation) -> Error? {
        
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
}
