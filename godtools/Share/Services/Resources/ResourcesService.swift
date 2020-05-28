//
//  ResourcesService.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesService: ResourcesServiceType {
    
    private let resourcesApi: ResourcesApiType
    
    let resourcesCache: ResourcesRealmCache
    
    required init(config: ConfigType, mainThreadRealm: Realm) {
        
        resourcesApi = ResourcesApi(config: config)
        resourcesCache = ResourcesRealmCache(mainThreadRealm: mainThreadRealm)
    }
    
    func downloadAndCacheResources() {
        
        print("\n DOWNLOAD AND CACHE RESOURCES")
        
        resourcesApi.getResourcesJson { [weak self] (result: Result<ResourcesJson, ResourcesApiError>) in
            
            print("  did download resources")
            
            switch result {
            case .success(let resourcesJson):
                self?.resourcesCache.cacheResources(resources: resourcesJson)
            case .failure(let apiError):
                break
            }
        }
    }
}
