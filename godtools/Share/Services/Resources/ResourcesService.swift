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
    private let resourcesCache: ResourcesCacheType
    
    required init(config: ConfigType, mainThreadRealm: Realm) {
        
        resourcesApi = ResourcesApi(config: config)
        resourcesCache = RealmResourcesCache(mainThreadRealm: mainThreadRealm)
    }
    
    func downloadAndCacheResources() {
        
        resourcesApi.getResourcesJson { [weak self] (result: Result<ResourcesJson, ResourcesApiError>) in
            
            switch result {
            case .success(let resourcesJson):
                break
            case .failure(let apiError):
                break
            }
        }
    }
}
