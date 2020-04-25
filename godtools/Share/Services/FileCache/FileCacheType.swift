//
//  FileCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FileCacheType {
    
    var fileManager: FileManager { get }
    var errorDomain: String { get }
    
    func getRootDirectory() -> Result<URL, Error>
    func getDirectory(location: FileCacheLocationType) -> Result<URL, Error>
    func getFile(location: FileCacheLocationType) -> Result<URL, Error>
    func cache(location: FileCacheLocationType, data: Data) -> Result<URL, Error>
    func getData(location: FileCacheLocationType) -> Result<Data?, Error>
    func fileExists(location: FileCacheLocationType) -> Result<Bool, Error>
}

extension FileCacheType {
    
    func getDirectory(location: FileCacheLocationType) -> Result<URL, Error> {
        
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

    func getFile(location: FileCacheLocationType) -> Result<URL, Error> {
        
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
    
    private func createDirectoryIfNotExists(location: FileCacheLocationType) -> Result<URL, Error> {
        
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
    
    func cache(location: FileCacheLocationType, data: Data) -> Result<URL, Error> {
        
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
    
    func getData(location: FileCacheLocationType) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func fileExists(location: FileCacheLocationType) -> Result<Bool, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.fileExists(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
}
