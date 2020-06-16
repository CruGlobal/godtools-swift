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
    
    let realmCache: ResourcesRealmCache
    let attachmentsFileCache: AttachmentsFileCache
    let translationsFileCache: TranslationsFileCache
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmCache = ResourcesRealmCache(realmDatabase: realmDatabase)
        self.attachmentsFileCache = AttachmentsFileCache(realmDatabase: realmDatabase, sha256FileCache: sha256FileCache)
        self.translationsFileCache = TranslationsFileCache(realmDatabase: realmDatabase, sha256FileCache: sha256FileCache)
    }
}
