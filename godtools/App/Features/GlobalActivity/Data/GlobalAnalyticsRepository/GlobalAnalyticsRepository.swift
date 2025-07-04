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

class GlobalAnalyticsRepository {
        
    private let api: MobileContentGlobalAnalyticsApi
    private let cache: RealmGlobalAnalyticsCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: MobileContentGlobalAnalyticsApi, cache: RealmGlobalAnalyticsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func getGlobalAnalyticsChangedPublisher(requestPriority: RequestPriority) -> AnyPublisher<GlobalAnalyticsDataModel?, Never> {
                
        getGlobalAnalyticsFromRemotePublisher(requestPriority: requestPriority)
            .sink { value in
                
            } receiveValue: { value in
                                
            }
            .store(in: &cancellables)
            
        return cache.getGlobalAnalyticsChangedPublisher(id: MobileContentGlobalAnalyticsApi.sharedGlobalAnalyticsId)
            .eraseToAnyPublisher()
    }
    
    private func getGlobalAnalyticsFromRemotePublisher(requestPriority: RequestPriority) -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        return api.getGlobalAnalyticsPublisher(requestPriority: requestPriority)
            .flatMap({ (globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> in
                
                return self.cache.storeGlobalAnalyticsPublisher(globalAnalytics: globalAnalytics)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
