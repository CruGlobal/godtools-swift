//
//  FollowUpsService.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class FollowUpsService {
    
    private let api: FollowUpsApi
    private let cache: FailedFollowUpsCache
            
    init(api: FollowUpsApi, cache: FailedFollowUpsCache) {

        self.api = api
        self.cache = cache
    }
    
    func postFollowUpPublisher(followUp: FollowUpModel, requestPriority: RequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
                            
        return api.postFollowUpPublisher(followUp: followUp, requestPriority: requestPriority)
            .mapError { (error: Error) in
                
                self.cache.cacheFailedFollowUps(followUps: [followUp])
                
                return error
            }
            .map { (response: RequestDataResponse) in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400
                                
                if httpStatusCodeFailed {
                    self.cache.cacheFailedFollowUps(followUps: [followUp])
                }
                
                return response
            }
            .eraseToAnyPublisher()
    }
    
    func postFailedFollowUpsIfNeededPublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Never> {
                
        let failedFollowUps: [FollowUpModel] = cache.getFailedFollowUps()
                
        guard !failedFollowUps.isEmpty else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        var successfulPostedFollowUps: [FollowUpModel] = Array()
        var requestCompletionCount: Int = 0
        
        let requests: [AnyPublisher<Bool, Never>] = failedFollowUps.map { (followUp: FollowUpModel) in
            
            return self.api.postFollowUpPublisher(
                followUp: followUp,
                requestPriority: requestPriority
            )
            .map { (response: RequestDataResponse) in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let httpStatusCodeSuccess: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                                
                return httpStatusCodeSuccess
            }
            .catch { _ in
                return Just(false)
                    .eraseToAnyPublisher()
            }
            .map { (isSuccess: Bool) in
                
                requestCompletionCount += 1
                                
                if isSuccess {
                    successfulPostedFollowUps.append(followUp)
                }
                
                let isLastRequest: Bool = requestCompletionCount == failedFollowUps.count
                                
                if isLastRequest {
                    self.cache.deleteFollowUps(followUps: successfulPostedFollowUps)
                }
                
                return isSuccess
            }
            .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(requests)
            .map { _ in
                return Void()
            }
            .eraseToAnyPublisher()
    }
}
