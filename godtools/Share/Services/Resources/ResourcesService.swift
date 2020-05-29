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
    
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    
    let resourcesCache: ResourcesRealmCache
    
    required init(config: ConfigType, mainThreadRealm: Realm) {
        
        languagesApi = LanguagesApi(config: config)
        resourcesApi = ResourcesApi(config: config)
        resourcesCache = ResourcesRealmCache(mainThreadRealm: mainThreadRealm)
    }
    
    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments() {
        
        print("\n DOWNLOAD AND CACHE RESOURCES")
        
        // TODO Implement new resource downloading and cacheing. ~Levi
        
    }
    
    // TODO: Need to implement this back in.
    private func handleGetResourcesJsonComplete(resourcesResponse: RequestResponse, languagesResponse: RequestResponse, complete: @escaping ((_ result: Result<ResourcesJson, ResourcesApiError>) -> Void)) {
        
        let error: Error? = resourcesResponse.error ?? languagesResponse.error
        
        if let error = error {
            
            let resourcesApiError: ResourcesApiError
            
            if error.notConnectedToInternet {
                resourcesApiError = .noNetworkConnection
            }
            else if error.isCancelled {
                resourcesApiError = .cancelled
            }
            else {
                resourcesApiError = .unknownError(error: error)
            }
            
            complete(.failure(resourcesApiError))
        }
        else {
            
            let resourcesJson = ResourcesJson(
                resourcesPlusLatestTranslationsAndAttachmentsJson: resourcesResponse.data,
                languagesJson: languagesResponse.data
            )
            complete(.success(resourcesJson))
        }
    }
}
