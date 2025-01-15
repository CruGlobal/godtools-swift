//
//  RemoteConfigRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import Combine

class RemoteConfigRepository {
    
    private static let sharedRemoteConfigId: String = "RemoteConfigRepository.shared.remoteConfig.id"
    
    private let api: RemoteConfigApiInterface
    private let cache: RemoteConfigCache
    
    init(api: RemoteConfigApiInterface, cache: RemoteConfigCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func getRemoteConfigChangedPublisher(id: String = RemoteConfigRepository.sharedRemoteConfigId) -> AnyPublisher<RemoteConfigDataModel?, Never> {
        
        return cache.getRemoteConfigChangedPublisher(id: id)
            .eraseToAnyPublisher()
    }
}
