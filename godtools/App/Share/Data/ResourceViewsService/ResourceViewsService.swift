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
    private let cache: FailedResourceViewsCache
    
    init(api: ResourceViewsApiInterface, cache: FailedResourceViewsCache) {
            
        self.api = api
        self.cache = cache
    }
    
    func postNewResourceView(resourceId: String, requestPriority: RequestPriority) async throws {
        
        let id: String = resourceId
        
        let resourceView = ResourceViewDataModel(
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
                
                try await cache.cacheFailedResourceViews(resourceViews: [resourceView])
            }
        }
        catch let error {
            
            try await cache.cacheFailedResourceViews(resourceViews: [resourceView])
            
            throw error
        }
    }
    
    func postFailedResourceViewsIfNeeded(requestPriority: RequestPriority) async throws {
                
        let failedResourceViews: [ResourceViewDataModel] = try await cache.persistence.getDataModels(getOption: .allObjects)
        
        guard !failedResourceViews.isEmpty else {
            return
        }
        
        var errors: [Error] = Array()
        
        for failedResourceView in failedResourceViews {
            
            do {
                
                try await postAndRemoveFailedResourceViews(
                    resourceView: failedResourceView,
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
    
    private func postAndRemoveFailedResourceViews(resourceView: ResourceViewDataModel, requestPriority: RequestPriority) async throws {
        
        let response = try await api.postResourceView(
            resourceId: resourceView.resourceId,
            quantity: resourceView.quantity,
            requestPriority: requestPriority
        )
        
        if response.urlResponse.isSuccessHttpStatusCode {
            _ = try await cache.persistence.deleteObjectsByIds(ids: [resourceView.id], getOption: nil)
        }
    }
}
