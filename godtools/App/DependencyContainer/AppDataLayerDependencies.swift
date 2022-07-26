//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDataLayerDependencies {
    
    private let sharedRealmDatabase: RealmDatabase = RealmDatabase()
    private let sharedIgnoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    
    init() {
        
    }
    
    func getAppConfig() -> AppConfig {
        return AppConfig()
    }
    
    func getAttachmentsRepository() -> AttachmentsRepository {
        
        return AttachmentsRepository(
            api: MobileContentAttachmentsApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmAttachmentsCache(realmDatabase: sharedRealmDatabase),
            resourcesFileCache: getResourcesFileCache()
        )
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        
        return LanguagesRepository(
            api: MobileContentLanguagesApi(config: getAppConfig(), ignoreCacheSession: sharedIgnoreCacheSession),
            cache: RealmLanguagesCache(realmDatabase: sharedRealmDatabase)
        )
    }
    
    private func getResourcesFileCache() -> ResourcesSHA256FileCache {
        return ResourcesSHA256FileCache(realmDatabase: sharedRealmDatabase)
    }
}
