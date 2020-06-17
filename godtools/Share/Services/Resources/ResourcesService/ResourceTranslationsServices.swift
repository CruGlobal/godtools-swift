//
//  ResourceTranslationsServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceTranslationsServices {
    
    typealias ResourceId = String
    
    private let realmDatabase: RealmDatabase
    private let realmResourcesCache: RealmResourcesCache
    private let translationsApi: TranslationsApiType
    private let sha256FileCache: SHA256FilesCache
    
    private var services: [ResourceId: ResourceTranslationsService] = Dictionary()
    
    required init(realmDatabase: RealmDatabase, realmResourcesCache: RealmResourcesCache, translationsApi: TranslationsApiType, sha256FileCache: SHA256FilesCache) {
        
        self.realmDatabase = realmDatabase
        self.realmResourcesCache = realmResourcesCache
        self.translationsApi = translationsApi
        self.sha256FileCache = sha256FileCache
    }
    
    func downloadAndCacheTranslations(resource: ResourceModel) {
        let service: ResourceTranslationsService = getService(resourceId: resource.id)
        if !service.started.value {
            service.downloadAndCacheTranslations(resource: resource)
        }
    }
    
    func getService(resourceId: String) -> ResourceTranslationsService {
        
        if let service = services[resourceId] {
            return service
        }
        
        let newService =  ResourceTranslationsService(
            realmDatabase: realmDatabase,
            realmResourcesCache: realmResourcesCache,
            translationsApi: translationsApi,
            sha256FileCache: sha256FileCache,
            resourceId: resourceId
        )
        
        services[resourceId] = newService
        
        return newService
    }
}
