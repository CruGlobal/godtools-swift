//
//  OptInNotificationRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationRepository: OptInNotificationRepositoryInterface {
    
    private let cache: OptInNotificationsUserDefaultsCache

    init(cache: OptInNotificationsUserDefaultsCache) {
        self.cache = cache
    }

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
