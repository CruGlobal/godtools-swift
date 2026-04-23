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
        
        var errors: [Error] = Array()
        
        for failedFollowUp in failedFollowUps {
            
            do {
                
                try await postAndRemoveFailedFollowUp(
                    failedFollowUp: failedFollowUp,
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
    
    private func postAndRemoveFailedFollowUp(failedFollowUp: FollowUpDataModel, requestPriority: RequestPriority) async throws {
        
        let response = try await api.postFollowUp(
            followUp: failedFollowUp.toFollowUp(),
            requestPriority: requestPriority
        )
        
        if response.urlResponse.isSuccessHttpStatusCode {
            cache.deleteFollowUps(followUps: [failedFollowUp])
        }
    }
}
