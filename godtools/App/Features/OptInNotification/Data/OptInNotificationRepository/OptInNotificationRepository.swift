//
//  OptInNotificationRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationRepository: OptInNotificationRepositoryInterface {
    
    private let cache: OptInNotificationUserDefaultsCache
    private let remoteConfigRepository: RemoteConfigRepository

    init(cache: OptInNotificationUserDefaultsCache, remoteConfigRepository: RemoteConfigRepository) {
        self.cache = cache
        self.remoteConfigRepository = remoteConfigRepository
    }
    
    // remoteConfig
    private var remoteConfigData: RemoteConfigDataModel? {
            remoteConfigRepository.getRemoteConfig()
        }
    
    func getRemoteFeatureEnabled() -> Bool {
        return remoteConfigData?.optInNotificationEnabled ?? true
    }
    
    func getRemoteTimeInterval() -> Date {
        let days =  remoteConfigData?.optInNotificationTimeInterval ?? 41
        
        let seconds = TimeInterval(days * 24 * 60 * 60)
        let date = Date().addingTimeInterval(-seconds)
        
        return date
    }
    
    func getRemotePromptLimit() -> Int {
        return remoteConfigData?.optInNotificationPromptLimit ?? 5
    }
    
    // cache
    func getLastPrompted() -> Date? {
        return cache.getLastPrompted()
    }
    
    func getPromptCount() -> Int {
        cache.getPromptCount()
    }
    
    func recordPrompt() {
        cache.recordPrompt()
    }
}
