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
    
    private static let globalAnalyticsChanged: CurrentValueSubject<MobileContentGlobalAnalyticsDataModel?, Never> = CurrentValueSubject(nil)
    
    private let api: MobileContentGlobalAnalyticsApi
    private let cache: GlobalAnalyticsUserDefaultsCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: MobileContentGlobalAnalyticsApi, cache: GlobalAnalyticsUserDefaultsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func getGlobalAnalyticsChangedPublisher() -> AnyPublisher<MobileContentGlobalAnalyticsDataModel?, Never> {
        
        getGlobalAnalyticsFromRemote()
            .sink { finished in
                
            } receiveValue: { (dataModel: MobileContentGlobalAnalyticsDataModel) in
                
                GlobalAnalyticsRepository.globalAnalyticsChanged.send(dataModel)
            }
            .store(in: &cancellables)
        
        GlobalAnalyticsRepository.globalAnalyticsChanged.value = cache.getGlobalAnalytics()

        return GlobalAnalyticsRepository.globalAnalyticsChanged
            .eraseToAnyPublisher()
    }
    
    func getGlobalAnalyticsFromRemote() -> AnyPublisher<MobileContentGlobalAnalyticsDataModel, URLResponseError> {
        
        return api.getGlobalAnalyticsPublisher()
            .flatMap({ (globalAnalytics: MobileContentGlobalAnalyticsDataModel) -> AnyPublisher<MobileContentGlobalAnalyticsDataModel, Never> in
                
                return self.cache.storeGlobalAnalyticsPublisher(globalAnalytics: globalAnalytics)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (globalAnalytics: MobileContentGlobalAnalyticsDataModel) -> AnyPublisher<MobileContentGlobalAnalyticsDataModel, URLResponseError> in
                
                return Just(globalAnalytics).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
