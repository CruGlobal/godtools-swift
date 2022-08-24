//
//  FollowUpsService.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class FollowUpsService {
    
    private let followUpsApi: FollowUpsApi
    private let failedFollowUpsCache: FailedFollowUpsCache
    
    required init(config: AppConfig, sharedSession: SharedIgnoreCacheSession, failedFollowUpsCache: FailedFollowUpsCache) {
        
        self.followUpsApi = FollowUpsApi(config: config, sharedSession: sharedSession)
        self.failedFollowUpsCache = failedFollowUpsCache
    }
    
    func postNewFollowUp(followUp: FollowUpModel) -> OperationQueue {
        
        return followUpsApi.postFollowUp(followUp: followUp) { [weak self] (response: RequestResponse) in
            
            let httpStatusCode: Int = response.httpStatusCode ?? -1
            let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400
            
            if httpStatusCodeFailed {
                self?.failedFollowUpsCache.cacheFailedFollowUps(followUps: [followUp])
            }
        }
    }
    
    func postFailedFollowUpsIfNeeded() -> OperationQueue? {
        
        let failedFollowUps: [FollowUpModel] = failedFollowUpsCache.getFailedFollowUps()
        
        guard !failedFollowUps.isEmpty else {
            return nil
        }
        
        let queue = OperationQueue()
        
        var operations: [RequestOperation] = Array()
        var successfulPostedFollowUps: [FollowUpModel] = Array()
                
        for followUp in failedFollowUps {
            
            let operation: RequestOperation = followUpsApi.newFollowUpsOperation(followUp: followUp)
            
            operations.append(operation)
            
            operation.setCompletionHandler { [weak self] (response: RequestResponse) in
                
                let httpStatusCode: Int = response.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                let isConnectedToNetwork: Bool = !response.notConnectedToInternet
                let failedForBadRequest: Bool = !httpStatusCodeSuccess && isConnectedToNetwork
                
                if httpStatusCodeSuccess || failedForBadRequest {
                    
                    successfulPostedFollowUps.append(followUp)
                }
                
                if queue.operations.isEmpty {
                    self?.failedFollowUpsCache.deleteFollowUps(followUps: successfulPostedFollowUps)
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)
        
        return queue
    }
}
