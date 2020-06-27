//
//  ViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ViewsService: ViewsServiceType {
    
    private let viewsApi: ViewsApiType
    private let failedViewedResourcesCache: RealmFailedViewedResourcesCache
    
    required init(config: ConfigType, realmDatabase: RealmDatabase) {
        
        viewsApi = ViewsApi(config: config)
        failedViewedResourcesCache = RealmFailedViewedResourcesCache(realmDatabase: realmDatabase)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func addNewResourceViews(resourceIds: [String]) -> OperationQueue? {
        
        guard !resourceIds.isEmpty else {
            return nil
        }
        
        let queue = OperationQueue()
        
        var operations: [RequestOperation] = Array()
        
        for resourceId in resourceIds {
            
            guard let resourceIdInt = Int(resourceId) else {
                continue
            }
            
            let operation = viewsApi.newAddViewsOperation(resourceId: resourceIdInt, quantity: 1)
            
            operations.append(operation)
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                                
                let httpStatusCode: Int = response.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                                    
                if !httpStatusCodeSuccess {
                    self?.failedViewedResourcesCache.cacheFailedViewedResource(
                        resourceId: resourceId,
                        incrementFailedViewCountBy: 1
                    )
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
    
    func addFailedResourceViewsIfNeeded() -> OperationQueue? {
            
        let queue = OperationQueue()
        let viewsApiRef: ViewsApiType = self.viewsApi
        
        failedViewedResourcesCache.getCachedFailedViewedResources(completeOnMain: { [weak self] (cachedFailedViewedResources: [FailedViewedResourceModel]) in
            
            guard !cachedFailedViewedResources.isEmpty else {
                return
            }
            
            var operations: [RequestOperation] = Array()
            
            for resourceView in cachedFailedViewedResources {
                
                guard let resourceIdInt = Int(resourceView.resourceId) else {
                    continue
                }
                
                let operation = viewsApiRef.newAddViewsOperation(resourceId: resourceIdInt, quantity: resourceView.failedViewsCount)
                
                operations.append(operation)
                
                operation.completionHandler { [weak self] (response: RequestResponse) in
                                    
                    let httpStatusCode: Int = response.httpStatusCode ?? -1
                    let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                    
                    if httpStatusCodeSuccess {
                        self?.failedViewedResourcesCache.deleteFailedViewedResourceFromCache(
                            resourceId: resourceView.resourceId
                        )
                    }
                    else {
                        // If we fail to update the resource view count, leave it in the cache for next time.
                    }
                    
                    if queue.operations.isEmpty {
                        
                    }
                }
            }
            
            queue.addOperations(operations, waitUntilFinished: false)
        })
        
        return queue
    }
}
