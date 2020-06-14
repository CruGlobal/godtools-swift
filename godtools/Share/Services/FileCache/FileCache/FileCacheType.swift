//
//  FileCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FileCacheType {
    
    associatedtype CacheLocation = FileCacheLocationType
        
    var fileManager: FileManager { get }
    var rootDirectory: String { get }
    var errorDomain: String { get }
    
    func getUserDocumentsDirectory() -> Result<URL, Error>
    func getRootDirectory() -> Result<URL, Error>
    func getDirectory(location: CacheLocation) -> Result<URL, Error>
    func getFile(location: CacheLocation) -> Result<URL, Error>
    func cache(location: CacheLocation, data: Data) -> Result<URL, Error>
    func getData(location: CacheLocation) -> Result<Data?, Error>
    func fileExists(location: CacheLocation) -> Result<Bool, Error>
    func removeRootDirectory() -> Error?
    func removeDirectory(location: CacheLocation) -> Error?
    func removeFile(location: CacheLocation) -> Error?
    func removeItem(url: URL) -> Error?
}
