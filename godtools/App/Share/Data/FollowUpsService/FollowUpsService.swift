//
//  FollowUpsService.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class FollowUpsService {
    
    private let api: FollowUpsApiInterface
    private let cache: FailedFollowUpsCache
            
    init(api: FollowUpsApiInterface, cache: FailedFollowUpsCache) {

        self.api = api
        self.cache = cache
    }
    
    func postFollowUp(followUp: FollowUp, requestPriority: RequestPriority) async throws {
        
        let followUpDataModel = followUp.toModel(id: UUID().uuidString)
        
        do {
            
            let response = try await api.postFollowUp(followUp: followUp, requestPriority: requestPriority)
            
            if !response.urlResponse.isSuccessHttpStatusCode {
                cache.cacheFailedFollowUps(followUps: [followUpDataModel])
            }
        }
        catch let error {
            cache.cacheFailedFollowUps(followUps: [followUpDataModel])
            
            throw error
        }
    }
    
    func postFailedFollowUpsIfNeeded(requestPriority: RequestPriority) async throws {
        
        let failedFollowUps: [FollowUpDataModel] = try cache.getFailedFollowUps()
        
        guard !failedFollowUps.isEmpty else {
            return
        }
        
        var successfulPostedFollowUps: [FollowUpDataModel] = Array()
        var requestCompletionCount: Int = 0
        
        for failedFollowUp in failedFollowUps {
            
            let response = try await api.postFollowUp(
                followUp: failedFollowUp.toFollowUp(),
                requestPriority: requestPriority
            )
            
            let isSuccess: Bool = response.urlResponse.isSuccessHttpStatusCode
            
            requestCompletionCount += 1
            
            if isSuccess {
                successfulPostedFollowUps.append(failedFollowUp)
            }
            
            let isLastRequest: Bool = requestCompletionCount == failedFollowUps.count
                            
            if isLastRequest {
                cache.deleteFollowUps(followUps: successfulPostedFollowUps)
            }
        }
    }
}
