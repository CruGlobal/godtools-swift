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

final class GlobalAnalyticsRepository {
    
    static let sharedGlobalAnalyticsId: String = "1"
        
    private let api: MobileContentGlobalAnalyticsApi
    private let cache: GlobalAnalyticsCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: MobileContentGlobalAnalyticsApi, cache: GlobalAnalyticsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    @MainActor func getGlobalAnalyticsChangedPublisher(requestPriority: RequestPriority) -> AnyPublisher<GlobalAnalyticsDataModel?, Error> {
                
        AnyPublisher() {
            return try await self.syncGlobalAnalyticsFromRemote(
                requestPriority: requestPriority
            )
        }
        .sink { value in
            
        } receiveValue: { value in
                            
        }
        .store(in: &cancellables)
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .tryMap {
                return try self.cache
                    .persistence
                    .getDataModel(
                        id: Self.sharedGlobalAnalyticsId
                    )
            }
            .eraseToAnyPublisher()
    }
    
    private func syncGlobalAnalyticsFromRemote(requestPriority: RequestPriority) async throws -> GlobalAnalyticsDataModel? {
        
        let globalAnalyticsCodable: MobileContentGlobalAnalyticsCodable? = try await api.getGlobalAnalytics(requestPriority: requestPriority)
        
        guard let globalAnalyticsCodable = globalAnalyticsCodable else {
            return nil
        }
        
        let sharedGlobalAnalytics = globalAnalyticsCodable.copy(id: Self.sharedGlobalAnalyticsId)
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [sharedGlobalAnalytics],
            writeOption: nil,
            getOption: nil
        )
        
        return sharedGlobalAnalytics.toModel()
    }
}
