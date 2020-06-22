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
    private let translationsFileCache: ResourceTranslationsFileCache
    
    private var services: [ResourceId: ResourceTranslationsService] = Dictionary()
    
    required init(realmDatabase: RealmDatabase, realmResourcesCache: RealmResourcesCache, translationsApi: TranslationsApiType, translationsFileCache: ResourceTranslationsFileCache) {
        
        self.realmDatabase = realmDatabase
        self.realmResourcesCache = realmResourcesCache
        self.translationsApi = translationsApi
        self.translationsFileCache = translationsFileCache
    }
    
    func downloadAndCacheTranslations(resource: ResourceModel) {
        let service: ResourceTranslationsService = getService(resourceId: resource.id)
        if !service.started.value {
            service.downloadAndCacheTranslations(resource: resource)
        }
    }
    
    func started(resource: ResourceModel) -> ObservableValue<Bool> {
        let service: ResourceTranslationsService = getService(resourceId: resource.id)
        return service.started
    }
    
    func progress(resource: ResourceModel) -> ObservableValue<Double> {
        let service: ResourceTranslationsService = getService(resourceId: resource.id)
        return service.progress
    }
    
    func complete(resource: ResourceModel) -> Signal {
        let service: ResourceTranslationsService = getService(resourceId: resource.id)
        return service.completed
    }
    
    private func getService(resourceId: String) -> ResourceTranslationsService {
        
        if let service = services[resourceId] {
            return service
        }
        
        let newService =  ResourceTranslationsService(
            realmDatabase: realmDatabase,
            realmResourcesCache: realmResourcesCache,
            translationsApi: translationsApi,
            translationsFileCache: translationsFileCache,
            resourceId: resourceId
        )
        
        services[resourceId] = newService
        
        return newService
    }
}
