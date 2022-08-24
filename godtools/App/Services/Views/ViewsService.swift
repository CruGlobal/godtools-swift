//
//  ViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class ViewsService {
    
    private let viewsApi: ViewsApi
    private let failedResourceViewsCache: FailedResourceViewsCache
    
    required init(config: AppConfig, realmDatabase: RealmDatabase, sharedSession: SharedIgnoreCacheSession) {
        
        viewsApi = ViewsApi(config: config, sharedSession: sharedSession)
        failedResourceViewsCache = FailedResourceViewsCache(realmDatabase: realmDatabase)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func postNewResourceView(resourceId: String) -> OperationQueue {
        
        let resourceView = ResourceViewModel(resourceId: resourceId)
        
        return viewsApi.postResourceView(resourceView: resourceView) { [weak self] (response: RequestResponse) in
            
            let httpStatusCode: Int = response.httpStatusCode ?? -1
            let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400
            
            if httpStatusCodeFailed {
                self?.failedResourceViewsCache.cacheFailedResourceViews(resourceViews: [resourceView])
            }
        }
    }
    
    func postFailedResourceViewsIfNeeded() -> OperationQueue? {
        
        let failedResourceViews: [ResourceViewModel] = failedResourceViewsCache.getFailedResourceViews()
        
        guard !failedResourceViews.isEmpty else {
            return nil
        }
        
        let queue = OperationQueue()
        
        var operations: [RequestOperation] = Array()
        var successfulPostedResourceViews: [ResourceViewModel] = Array()
                
        for resourceView in failedResourceViews {
            
            let operation: RequestOperation = viewsApi.newResourceViewOperation(resourceView: resourceView)
            
            operations.append(operation)
            
            operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                
                let httpStatusCode: Int = response.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                let isConnectedToNetwork: Bool = !response.notConnectedToInternet
                let failedForBadRequest: Bool = !httpStatusCodeSuccess && isConnectedToNetwork
                
                if httpStatusCodeSuccess || failedForBadRequest {
                    
                    successfulPostedResourceViews.append(resourceView)
                }
                
                if queue.operations.isEmpty {
                    self?.failedResourceViewsCache.deleteFailedResourceViews(resourceViews: successfulPostedResourceViews)
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
}
