//
//  ResourceViewsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class ResourceViewsService {
    
    private let resourceViewsApi: MobileContentResourceViewsApi
    private let failedResourceViewsCache: FailedResourceViewsCache
    
    init(resourceViewsApi: MobileContentResourceViewsApi, failedResourceViewsCache: FailedResourceViewsCache) {
            
        self.resourceViewsApi = resourceViewsApi
        self.failedResourceViewsCache = failedResourceViewsCache
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func postNewResourceViewPublisher(resourceId: String, sendRequestPriority: SendRequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
                
        let resourceView = ResourceViewModel(resourceId: resourceId)
        
        return resourceViewsApi.postResourceViewPublisher(resourceView: resourceView, sendRequestPriority: sendRequestPriority)
            .mapError { (error: Error) in
                
                self.failedResourceViewsCache.cacheFailedResourceViews(resourceViews: [resourceView])
                
                return error
            }
            .map { (response: RequestDataResponse) in
                
                let httpStatusCode: Int = response.urlResponse.httpStatusCode ?? -1
                let httpStatusCodeFailed: Bool = httpStatusCode < 200 || httpStatusCode >= 400
                                
                if httpStatusCodeFailed {
                    self.failedResourceViewsCache.cacheFailedResourceViews(resourceViews: [resourceView])
                }
                
                return response
            }
            .eraseToAnyPublisher()
    }
    
    func postFailedResourceViewsIfNeededPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<Void, Never> {
                
        let failedResourceViews: [ResourceViewModel] = failedResourceViewsCache.getFailedResourceViews()
                
        guard !failedResourceViews.isEmpty else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        var successfulPostedResourceViews: [ResourceViewModel] = Array()
        var requestCompletionCount: Int = 0
        
        let requests: [AnyPublisher<Bool, Never>] = failedResourceViews.map { (resourceView: ResourceViewModel) in
            
            return self.resourceViewsApi.postResourceViewPublisher(
                resourceView: resourceView,
                sendRequestPriority: sendRequestPriority
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
                    successfulPostedResourceViews.append(resourceView)
                }
                
                let isLastRequest: Bool = requestCompletionCount == failedResourceViews.count
                                
                if isLastRequest {
                    self.failedResourceViewsCache.deleteFailedResourceViews(resourceViews: successfulPostedResourceViews)
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
