//
//  GlobalAnalyticsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class GlobalAnalyticsRepository: Sendable {
    
    static let sharedGlobalAnalyticsId: String = "1"
        
    private let api: GlobalAnalyticsApiInterface
    private let cache: GlobalAnalyticsCache
        
    init(api: GlobalAnalyticsApiInterface, cache: GlobalAnalyticsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
                        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    func getGlobalAnalytics() -> GlobalAnalyticsDataModel? {
        
        do {
            return try self.cache
                .persistence
                .getDataModel(
                    id: Self.sharedGlobalAnalyticsId
                )
        }
        catch _ {
            return nil
        }
    }
}
