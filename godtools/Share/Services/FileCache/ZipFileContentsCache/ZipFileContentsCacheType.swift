//
//  ZipFileContentsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ZipFileContentsCacheType {
        
    associatedtype CacheLocation = ZipFileContentsCacheLocationType
    
    var fileManager: FileManager { get }
    var rootDirectory: String { get }
    var errorDomain: String { get }
    
    func getUserDocumentsDirectory() -> Result<URL, Error>
    func getRootDirectory() -> Result<URL, Error>
    func getContentsDirectory(location: CacheLocation) -> Result<URL, Error>
    func deleteContentsDirectory(location: CacheLocation) -> Result<URL, Error>
    func createNewContentsDirectory(location: CacheLocation) -> Result<URL, Error>
    func cacheContents(location: CacheLocation, zipData: Data) -> Result<URL, Error>
    func getData(url: URL) -> Data?
    func getContentsUrls(location: CacheLocation) -> Result<[URL], Error>
    func getContentsPaths(location: CacheLocation) -> Result<[String], Error>
    func contentsExist(location: CacheLocation) -> Result<Bool, Error>
}
