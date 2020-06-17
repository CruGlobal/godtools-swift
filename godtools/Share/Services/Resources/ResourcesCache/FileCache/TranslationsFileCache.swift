//
//  TranslationsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationsFileCache {
    
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: SHA256FilesCache
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: SHA256FilesCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
}
