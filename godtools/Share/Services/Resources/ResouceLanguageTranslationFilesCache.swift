//
//  ResouceLanguageTranslationFilesCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceLanguageTranslationFilesCache {
    
    let cacheLocation: ResourcesLatestTranslationsZipFileCacheLocation
    let cache: ResourcesLatestTranslationsZipFileCache
    
    required init(resource: DownloadedResource, language: Language, cache: ResourcesLatestTranslationsZipFileCache) {
        
        cacheLocation = ResourcesLatestTranslationsZipFileCacheLocation(resource: resource, language: language)
        self.cache = cache
    }
    
    func getFile(filename: String) -> Result<Data?, Error> {
        
        return cache.getData(location: cacheLocation, path: filename)
    }
}
