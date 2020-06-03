//
//  ResourcesLatestTranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesLatestTranslationsFileCache: ZipFileContentsCache<ResourcesLatestTranslationsFileCacheLocation> {
        
    required init() {
        super.init(rootDirectory: "resource_translations")
    }
    
    required init(rootDirectory: String) {
        fatalError("ResourcesLatestTranslationsFileCache: init(rootDirectory: should not be used.  Instead, use init() to initialize with the correct rootDirectory.")
    }
    
    func getCachedManifestXmlData(cacheLocation: ResourcesLatestTranslationsFileCacheLocation, translationManifestFileName: String) -> Data? {
                
        let fileContentsExist: Bool
        switch contentsExist(location: cacheLocation) {
        case .success(let exist):
            fileContentsExist = exist
        case .failure( _):
            fileContentsExist = false
        }
        
        var cachedXmlData: Data?
        if fileContentsExist {
            switch getData(location: cacheLocation, path: translationManifestFileName) {
            case .success(let xmlData):
                cachedXmlData = xmlData
            case .failure( _):
                break
            }
        }
        
        return cachedXmlData
    }
    
    func cacheTranslationZipData(cacheLocation: ResourcesLatestTranslationsFileCacheLocation, zipData: Data) -> Error? {
                
        switch cacheContents(location: cacheLocation, zipData: zipData) {
        case .success( _):
            return nil
        case .failure(let error):
            return error
        }
    }
}
