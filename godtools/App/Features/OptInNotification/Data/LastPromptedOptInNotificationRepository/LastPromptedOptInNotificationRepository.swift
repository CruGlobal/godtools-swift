//
//  LastPromptedOptInNotificationRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LastPromptedOptInNotificationRepository {
    private let cache: LastPromptedOptInNotificationUserDefaultsCache

    init(cache: LastPromptedOptInNotificationUserDefaultsCache) {
        self.cache = cache
    }

    func getLastPrompted() -> String? {
        return cache.getLastPrompted()
    }

    func recordLastPrompted(dateString: String) {
        cache.recordLastPrompted(dateString: dateString)
    }
}
