//
//  ResourceViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class ResourceViewsService {
    
    private let api: ResourceViewsApiInterface
    private let failedResourceViewsCache: FailedResourceViewsCache
    
    init(api: ResourceViewsApiInterface, failedResourceViewsCache: FailedResourceViewsCache) {
            
        self.api = api
        self.failedResourceViewsCache = failedResourceViewsCache
    }
    
    func postNewResourceView(resourceId: String, requestPriority: RequestPriority) async throws {
        
        let id: String = resourceId
        
        let resourceView = ResourceViewsDataModel(
            id: id,
            resourceId: id,
            quantity: 1
        )
        
        do {
            
            let response = try await api.postResourceView(
                resourceId: resourceView.resourceId,
                quantity: resourceView.quantity,
                requestPriority: requestPriority
            )
            
            if !response.urlResponse.isSuccessHttpStatusCode {
                
                failedResourceViewsCache.cacheFailedResourceViews(resourceViews: [resourceView])
            }
        }
        catch let error {
            
            failedResourceViewsCache.cacheFailedResourceViews(resourceViews: [resourceView])
            
            throw error
        }
    }
    
    func postFailedResourceViewsIfNeeded(requestPriority: RequestPriority) async throws {
                
        let failedResourceViews: [ResourceViewsDataModel] = try failedResourceViewsCache.getFailedResourceViews()
        
        guard !failedResourceViews.isEmpty else {
            return
        }
        
        var errors: [Error] = Array()
        
        for failedResourceView in failedResourceViews {
            
            do {
                
                try await postAndRemoveFailedResourceViews(
                    resourceViews: failedResourceView,
                    requestPriority: requestPriority
                )
            }
            catch let error {
                errors.append(error)
            }
        }
        
        if let error = errors.first {
            throw error
        }
    }
    
    private func postAndRemoveFailedResourceViews(resourceViews: ResourceViewsDataModel, requestPriority: RequestPriority) async throws {
        
        let response = try await api.postResourceView(
            resourceId: resourceViews.resourceId,
            quantity: resourceViews.quantity,
            requestPriority: requestPriority
        )
        
        if response.urlResponse.isSuccessHttpStatusCode {
            failedResourceViewsCache.deleteFailedResourceViews(resourceViews: [resourceViews])
        }
    }
}
