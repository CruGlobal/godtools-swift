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
    private let failedResourceViewsCache: FailedResourceViewsCache
    
    required init(config: ConfigType, realmDatabase: RealmDatabase) {
        
        viewsApi = ViewsApi(config: config)
        failedResourceViewsCache = FailedResourceViewsCache(realmDatabase: realmDatabase)
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
        
        var failedResourceViews: [String] = Array()
        
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
                    failedResourceViews.append(resourceId)
                }
                
                if queue.operations.isEmpty {
                    
                    if !failedResourceViews.isEmpty {
                        self?.failedResourceViewsCache.cacheFailedResourceViews(
                            resourceIds: failedResourceViews,
                            incrementFailedViewCountBy: 1
                        )
                    }
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
    
    func addFailedResourceViewsIfNeeded() -> OperationQueue? {
            
        let queue = OperationQueue()
        let viewsApiRef: ViewsApiType = self.viewsApi
        
        let failedResourceViews: [FailedResourceViewModel] = failedResourceViewsCache.getFailedResourceViews()
        
        guard !failedResourceViews.isEmpty else {
            return nil
        }
        
        var operations: [RequestOperation] = Array()
        
        for failedResourceView in failedResourceViews {
            
            guard let resourceIdInt = Int(failedResourceView.resourceId) else {
                continue
            }
            
            let operation = viewsApiRef.newAddViewsOperation(resourceId: resourceIdInt, quantity: failedResourceView.failedViewsCount)
            
            operations.append(operation)
            
            var successfulResourceViews: [String] = Array()
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                                
                let httpStatusCode: Int = response.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                
                if httpStatusCodeSuccess {
                    successfulResourceViews.append(failedResourceView.resourceId)
                }
                else {
                    // If we fail to update the resource view count, leave it in the cache for next time.
                }
                
                if queue.operations.isEmpty {
                    
                    if !successfulResourceViews.isEmpty {
                        self?.failedResourceViewsCache.deleteFailedResourceViews(resourceIds: successfulResourceViews)
                    }
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
}
