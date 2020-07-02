//
//  FollowUpsService.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FollowUpsService {
    
    private let followUpsApi: FollowUpsApi
    private let failedFollowUpsCache: FailedFollowUpsCache
    
    required init(config: ConfigType, realmDatabase: RealmDatabase, sharedSession: SharedSessionType) {
        
        followUpsApi = FollowUpsApi(config: config, sharedSession: sharedSession)
        failedFollowUpsCache = FailedFollowUpsCache(realmDatabase: realmDatabase)
    }
    
    func postNewFollowUp(followUp: FollowUpModel) -> OperationQueue {
        
        return followUpsApi.postFollowUp(followUp: followUp) { [weak self] (response: RequestResponse) in
            
            let httpStatusCode: Int = response.httpStatusCode ?? -1
            let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
            
            if !httpStatusCodeSuccess && response.notConnectedToInternet {
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
            
            operation.completionHandler { [weak self] (response: RequestResponse) in
                
                let httpStatusCode: Int = response.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                
                if httpStatusCodeSuccess {
                    
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
