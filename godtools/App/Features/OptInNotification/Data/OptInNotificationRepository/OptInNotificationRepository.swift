//
//  OptInNotificationRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class OptInNotificationRepository: OptInNotificationRepositoryInterface {
    
    private let cache: OptInNotificationUserDefaultsCache
    private let remoteConfigRepository: RemoteConfigRepository

    init(cache: OptInNotificationUserDefaultsCache, remoteConfigRepository: RemoteConfigRepository) {
        self.cache = cache
        self.remoteConfigRepository = remoteConfigRepository
    }
    
    private var remoteConfigData: RemoteConfigDataModel? {
        get async {
            await remoteConfigRepository.getRemoteConfig()
        }
    }
    
    func getRemoteFeatureEnabled() async -> Bool {
        return await remoteConfigData?.optInNotificationEnabled ?? true
    }
    
    func getRemoteTimeInterval() async -> Date {
        let days =  await remoteConfigData?.optInNotificationTimeInterval ?? 41
        
        let seconds = TimeInterval(days * 24 * 60 * 60)
        let date = Date().addingTimeInterval(-seconds)
        
        return date
    }
    
    func getRemotePromptLimit() async -> Int {
        return await remoteConfigData?.optInNotificationPromptLimit ?? 5
    }
    
    func getLastPrompted() async -> Date? {
        return await cache.getLastPrompted()
    }
    
    func getPromptCount() async -> Int {
        await cache.getPromptCount()
    }
    
    func recordPrompt() async {
        await cache.recordPrompt()
    }
}
