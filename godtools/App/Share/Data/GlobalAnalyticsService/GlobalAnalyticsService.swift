//
//  GlobalAnalyticsService.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class GlobalAnalyticsService {
    
    private let api: MobileContentGlobalAnalyticsApi
    private let cache: GlobalAnalyticsUserDefaultsCache
    
    init(api: MobileContentGlobalAnalyticsApi, cache: GlobalAnalyticsUserDefaultsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    var cachedGlobalAnalytics: MobileContentGlobalAnalyticsDataModel? {
        return cache.getGlobalActivityAnalytics()
    }
    
    func getGlobalAnalytics(complete: @escaping ((_ result: Result<MobileContentGlobalAnalyticsDataModel?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        return api.getGlobalAnalytics { [weak self] (result: Result<MobileContentGlobalAnalyticsDataModel?, RequestResponseError<NoHttpClientErrorResponse>>) in
                        
            switch result {
                
            case .success(let globalActivityAnalytics):
                if let globalActivityAnalytics = globalActivityAnalytics {
                    self?.cache.cacheGlobalActivityAnalytics(globalAnalytics: globalActivityAnalytics)
                }
                complete(result)
            case .failure( _):
                if let cachedGlobalActivityAnalytics = self?.cache.getGlobalActivityAnalytics() {
                    complete(.success(cachedGlobalActivityAnalytics))
                }
                else {
                    complete(result)
                }
            }
        }
    }
}
