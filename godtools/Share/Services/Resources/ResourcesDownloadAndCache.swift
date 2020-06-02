//
//  ResourcesDownloadAndCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesDownloadAndCache: ResourcesDownloadAndCacheType {
    
    private let languagesApi: LanguagesApiType
    private let resourcesApi: ResourcesApiType
    
    let resourcesCache: ResourcesRealmCache
    
    required init(config: ConfigType, mainThreadRealm: Realm) {
        
        languagesApi = LanguagesApi(config: config)
        resourcesApi = ResourcesApi(config: config)
        resourcesCache = ResourcesRealmCache(mainThreadRealm: mainThreadRealm)
    }
    
    func downloadAndCacheLanguagesPlusResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ error: ResourcesDownloadAndCacheError?) -> Void)) -> OperationQueue {
        
        print("\n DOWNLOAD AND CACHE RESOURCES")
        
        let queue = OperationQueue()
        
        let languagesOperation: RequestOperation = languagesApi.newGetLanguagesOperation()
        let resourcesPlusLatestTranslationsAndAttachmentsOperation: RequestOperation = resourcesApi.newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        let operations: [RequestOperation] = [languagesOperation, resourcesPlusLatestTranslationsAndAttachmentsOperation]
                
        var languagesResponse: RequestResponse?
        var resourcesResponse: RequestResponse?
        
        languagesOperation.completionHandler { [weak self] (response: RequestResponse) in
            
            languagesResponse = response
            
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResponse: languagesResponse,
                    resourcesResponse: resourcesResponse,
                    complete: complete
                )
            }
        }
        
        resourcesPlusLatestTranslationsAndAttachmentsOperation.completionHandler { [weak self] (response: RequestResponse) in
                
            resourcesResponse = response
            
            if queue.operations.isEmpty {
                
                self?.handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(
                    languagesResponse: languagesResponse,
                    resourcesResponse: resourcesResponse,
                    complete: complete
                )
            }
        }
        
        queue.addOperations(
            operations,
            waitUntilFinished: false
        )
        
        return queue
    }
    
    private var unknownError: Error {
        return NSError(
            domain: String(describing: ResourcesDownloadAndCache.self),
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]
        )
    }
    
    private func handleDownloadLanguagesPlusResourcesPlusLatestTranslationsAndAttachmentsCompleted(languagesResponse: RequestResponse?, resourcesResponse: RequestResponse?, complete: @escaping ((_ error: ResourcesDownloadAndCacheError?) -> Void)) {
        
        guard let languagesResponse = languagesResponse, let resourcesResponse = resourcesResponse else {
            complete(.internalErrorMissingResponseData)
            return 
        }
        
        let requestResponses: [RequestResponse] = [languagesResponse, resourcesResponse]
        
        for response in requestResponses {
            
            if response.notConnectedToInternet {
                complete(.noNetworkConnection)
                return
            }
            else if response.requestCancelled {
                complete(.cancelled)
                return
            }
        }
        
        if let languagesRequestError = languagesResponse.requestError {
            complete(.failedToGetLanguages(error: languagesRequestError, data: languagesResponse.data))
            return
        }
        else if languagesResponse.requestFailed {
            complete(.failedToGetLanguages(error: unknownError, data: languagesResponse.data))
            return
        }
        else if let resourcesRequestError = resourcesResponse.requestError {
            complete(.failedToGetResourcesPlusLatestTranslationsAndAttachments(error: resourcesRequestError, data: resourcesResponse.data))
            return
        }
        else if resourcesResponse.requestFailed {
            complete(.failedToGetResourcesPlusLatestTranslationsAndAttachments(error: unknownError, data: resourcesResponse.data))
            return
        }
        
        let resources = ResourcesJson(
            resourcesPlusLatestTranslationsAndAttachmentsJson: resourcesResponse.data,
            languagesJson: languagesResponse.data
        )
        
        resourcesCache.cacheResources(resources: resources) { (error: ResourcesRealmCacheError?) in
            
            if let error = error {
                complete(.cacheError(error: error))
            }
            else {
                complete(nil)
            }
        }
    }
}
