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
    
    func getGlobalAnalyticsChangedPublisher() -> AnyPublisher<GlobalAnalyticsDataModel?, Never> {
        
        getGlobalAnalyticsFromRemote()
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
            
        return cache.getGlobalAnalyticsChangedPublisher(id: MobileContentGlobalAnalyticsApi.sharedGlobalAnalyticsId)
            .map { (realmGlobalAnalytics: RealmGlobalAnalytics?) in
                
                if let realmGlobalAnalytics = realmGlobalAnalytics {
                    return GlobalAnalyticsDataModel(realmGlobalAnalytics: realmGlobalAnalytics)
                }
                
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    func getGlobalAnalyticsFromRemote() -> AnyPublisher<GlobalAnalyticsDataModel, Error> {
        
        return api.getGlobalAnalyticsPublisher()
            .flatMap({ (globalAnalytics: MobileContentGlobalAnalyticsDecodable) -> AnyPublisher<GlobalAnalyticsDataModel, Error> in
                
                return self.cache.storeGlobalAnalyticsPublisher(globalAnalytics: globalAnalytics)
                    .map {
                        return GlobalAnalyticsDataModel(mobileContentAnalyticsDecodable: $0)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
