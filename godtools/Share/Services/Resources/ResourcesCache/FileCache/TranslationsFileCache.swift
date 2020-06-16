//
//  TranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationsFileCache {
    
    private let realmResources: RealmResourcesCache
    private let sha256FileCache: SHA256FilesCache
    
    required init(realmResources: RealmResourcesCache, realmSHA256FileCache: RealmSHA256FileCache, sha256FileCache: SHA256FilesCache) {
        
        self.realmResources = realmResources
        self.sha256FileCache = sha256FileCache
    }
}
