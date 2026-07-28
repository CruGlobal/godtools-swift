//
//  GlobalAnalyticsSync.swift
//  godtools
//
//  Created by Levi Eggert on 7/28/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class GlobalAnalyticsSync: Sendable {
    
    private let api: GlobalAnalyticsApiInterface
    private let cache: GlobalAnalyticsCache
        
    init(api: GlobalAnalyticsApiInterface, cache: GlobalAnalyticsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func sync(requestPriority: RequestPriority) async throws {
        
        let globalAnalyticsCodable: MobileContentGlobalAnalyticsCodable? = try await api.getGlobalAnalytics(
            requestPriority: requestPriority
        )
        
        guard let globalAnalyticsCodable = globalAnalyticsCodable else {
            return
        }
        
        let sharedGlobalAnalytics = globalAnalyticsCodable.copy(id: GlobalAnalyticsRepository.sharedGlobalAnalyticsId)
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [sharedGlobalAnalytics],
            writeOption: nil,
            getOption: nil
        )
    }
}
