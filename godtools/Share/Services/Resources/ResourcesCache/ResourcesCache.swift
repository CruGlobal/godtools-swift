//
//  ResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesCache {
        
    private let sha256FileCache: SHA256FilesCache = SHA256FilesCache(rootDirectory: "resources_files")
    private let realmSHA256FileCache: RealmSHA256FileCache
    
    let realmResources: RealmResourcesCache
    let attachmentsFileCache: AttachmentsFileCache
    let translationsFileCache: TranslationsFileCache
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmResources = RealmResourcesCache(realmDatabase: realmDatabase)
        self.realmSHA256FileCache = RealmSHA256FileCache(realmDatabase: realmDatabase)
        self.attachmentsFileCache = AttachmentsFileCache(realmResources: realmResources, realmSHA256FileCache: realmSHA256FileCache, sha256FileCache: sha256FileCache)
        self.translationsFileCache = TranslationsFileCache(realmResources: realmResources, realmSHA256FileCache: realmSHA256FileCache, sha256FileCache: sha256FileCache)
    }
}
