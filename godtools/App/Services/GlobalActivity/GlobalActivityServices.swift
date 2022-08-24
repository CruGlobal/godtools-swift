//
//  GlobalActivityServices.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class GlobalActivityServices {
    
    private let globalActivityApi: GlobalActivityAnalyticsApi
    private let globalActivityCache: GlobalActivityAnalyticsCacheType
    
    required init(config: AppConfig, sharedSession: SharedIgnoreCacheSession) {
        
        self.globalActivityApi = GlobalActivityAnalyticsApi(config: config, sharedSession: sharedSession)
        self.globalActivityCache = GlobalActivityAnalyticsUserDefaultsCache()
    }
    
    var cachedGlobalAnalytics: GlobalActivityAnalytics? {
        return globalActivityCache.getGlobalActivityAnalytics()
    }
    
    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalActivityAnalytics?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        return globalActivityApi.getGlobalAnalytics { [weak self] (result: Result<GlobalActivityAnalytics?, RequestResponseError<NoHttpClientErrorResponse>>) in
                        
            switch result {
                
            case .success(let globalActivityAnalytics):
                if let globalActivityAnalytics = globalActivityAnalytics {
                    self?.globalActivityCache.cacheGlobalActivityAnalytics(globalAnalytics: globalActivityAnalytics)
                }
                complete(result)
            case .failure( _):
                if let cachedGlobalActivityAnalytics = self?.globalActivityCache.getGlobalActivityAnalytics() {
                    complete(.success(cachedGlobalActivityAnalytics))
                }
                else {
                    complete(result)
                }
            }
        }
    }
}
