//
//  GlobalAnalyticsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class GlobalAnalyticsRepository {
        
    private let api: MobileContentGlobalAnalyticsApi
    private let cache: RealmGlobalAnalyticsCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: MobileContentGlobalAnalyticsApi, cache: RealmGlobalAnalyticsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func getGlobalAnalyticsChangedPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<GlobalAnalyticsDataModel?, Never> {
                
        getGlobalAnalyticsFromRemotePublisher(sendRequestPriority: sendRequestPriority)
            .sink { value in
                
            } receiveValue: { value in
                                
            }
            .store(in: &cancellables)
            
        return cache.getGlobalAnalyticsChangedPublisher(id: MobileContentGlobalAnalyticsApi.sharedGlobalAnalyticsId)
            .eraseToAnyPublisher()
    }
    
    private func getGlobalAnalyticsFromRemotePublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        return api.getGlobalAnalyticsPublisher(sendRequestPriority: sendRequestPriority)
            .flatMap({ (globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> in
                
                return self.cache.storeGlobalAnalyticsPublisher(globalAnalytics: globalAnalytics)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
