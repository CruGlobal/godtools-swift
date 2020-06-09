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
        failedViewedResourcesCache = RealmFailedViewedResourcesCache(mainThreadRealm: realmDatabase.mainThreadRealm)
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
                                        
                    self?.failedViewedResourcesCache.cacheFailedViewedResource(resourceId: resourceId, incrementFailedViewCountBy: 1, complete: { (error: Error?) in
                        
                    })
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
    
    func addFailedResourceViewsIfNeeded() -> OperationQueue? {
            
        let queue = OperationQueue()
        let viewsApiRef: ViewsApiType = self.viewsApi
        
        failedViewedResourcesCache.getCachedFailedViewedResources { [weak self] (cachedFailedViewedResources: [RealmFailedViewedResource]) in
            
            guard !cachedFailedViewedResources.isEmpty else {
                return
            }
            
            var resourceViews: [ResourceView] = Array()
            
            for failedViewedResource in cachedFailedViewedResources {
                            
                let resouceView = ResourceView(
                    resourceId: failedViewedResource.resourceId,
                    quantity: failedViewedResource.failedViewsCount
                )
                
                resourceViews.append(resouceView)
            }
            
            var operations: [RequestOperation] = Array()
            
            for resourceView in resourceViews {
                
                guard let resourceIdInt = Int(resourceView.resourceId) else {
                    continue
                }
                
                let operation = viewsApiRef.newAddViewsOperation(resourceId: resourceIdInt, quantity: resourceView.quantity)
                
                operations.append(operation)
                
                operation.completionHandler { [weak self] (response: RequestResponse) in
                                    
                    let httpStatusCode: Int = response.httpStatusCode ?? -1
                    let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                    
                    if httpStatusCodeSuccess {
                        
                        self?.failedViewedResourcesCache.deleteFailedViewedResourceFromCache(resourceId: resourceView.resourceId, complete: { (error: Error?) in
                            
                        })
                    }
                    else {
                        // If we fail to update the resource view count, leave it in the cache for next time.
                    }
                }
            }
            
            queue.addOperations(operations, waitUntilFinished: false)
        }
        
        return queue
    }
}
