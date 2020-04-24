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
    func getFile(location: FileCacheLocationType) -> Result<URL, Error>
    func cache(location: FileCacheLocationType, data: Data) -> Result<URL, Error>
    func getDataLocation(location: FileCacheLocationType) -> Result<Data?, Error>
    func getData(url: URL) -> Data?
    func fileExists(location: FileCacheLocationType) -> Result<Bool, Error>
}

extension FileCache {
    
    func getFile(location: FileCacheLocationType) -> Result<URL, Error> {
        
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
    
    func cache(location: FileCacheLocationType, data: Data) -> Result<URL, Error> {
        
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
    
    func getDataLocation(location: FileCacheLocationType) -> Result<Data?, Error> {
        
        switch getFile(location: location) {
        case .success(let url):
            return .success(fileManager.contents(atPath: url.path))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getData(url: URL) -> Data? {
        return fileManager.contents(atPath: url.path)
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
