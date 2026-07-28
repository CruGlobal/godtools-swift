//
//  FollowUpsService.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class FollowUpsService: Sendable {
    
    private let api: FollowUpsApiInterface
    private let cache: FailedFollowUpsCache
            
    init(api: FollowUpsApiInterface, cache: FailedFollowUpsCache) {

        self.api = api
        self.cache = cache
    }
    
    func postFollowUp(followUp: FollowUp, requestPriority: RequestPriority) async throws {
        
        let followUpDataModel = FollowUpDataModel(
            id: UUID().uuidString,
            followUp: followUp
        )
        
        do {
            
            let response = try await api.postFollowUp(followUp: followUp, requestPriority: requestPriority)
            
            if !response.urlResponse.isSuccessHttpStatusCode {
                
                _ = try await cache.persistence.writeObjects(
                    externalObjects: [followUpDataModel],
                    writeOption: nil,
                    getOption: nil
                )
            }
        }
        catch let error {
            
            _ = try await cache.persistence.writeObjects(
                externalObjects: [followUpDataModel],
                writeOption: nil,
                getOption: nil
            )
            
            throw error
        }
    }
    
    func postFailedFollowUpsIfNeeded(requestPriority: RequestPriority) async throws {
        
        let failedFollowUps: [FollowUpDataModel] = try await cache.persistence.getDataModels(getOption: .allObjects)
        
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
            _ = try await cache.persistence.deleteObjectsByIds(ids: [failedFollowUp.id], getOption: nil)
        }
    }
}
