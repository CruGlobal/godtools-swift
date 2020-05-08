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
}
