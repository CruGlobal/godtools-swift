//
//  GlobalActivityServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GlobalActivityServices: GlobalActivityServicesType {
    
    private let globalActivityApi: GlobalActivityAnalyticsApiType
    private let globalActivityCache: GlobalActivityAnalyticsCacheType
    
    required init(globalActivityApi: GlobalActivityAnalyticsApiType, globalActivityCache: GlobalActivityAnalyticsCacheType) {
        
        self.globalActivityApi = globalActivityApi
        self.globalActivityCache = globalActivityCache
    }
    
    func getGlobalAnalytics(complete: @escaping ((_ response: RequestResponse, _ result: RequestResult<GlobalActivityAnalytics, RequestClientError>) -> Void)) -> OperationQueue {
        
        return globalActivityApi.getGlobalAnalytics { [weak self] (response: RequestResponse, result: RequestResult<GlobalActivityAnalytics, RequestClientError>) in
            
            switch result {
                
            case .success(let globalActivityAnalytics):
                if let globalActivityAnalytics = globalActivityAnalytics {
                    self?.globalActivityCache.cacheGlobalActivityAnalytics(globalAnalytics: globalActivityAnalytics)
                }
                complete(response, result)
            case .failure( _, _):
                if let cachedGlobalActivityAnalytics = self?.globalActivityCache.getGlobalActivityAnalytics() {
                    complete(response, .success(object: cachedGlobalActivityAnalytics))
                }
                else {
                    complete(response, result)
                }
            }
        }
    }
}
