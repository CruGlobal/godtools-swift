//
//  OptInNotificationDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationDataLayerDependencies {

    private let coreDataLayer: AppDataLayerDependencies

    init(coreDataLayer: AppDataLayerDependencies) {

        self.coreDataLayer = coreDataLayer
    }

    func getOptInNotificationRepository() -> OptInNotificationRepository {
        return OptInNotificationRepository(
            cache: OptInNotificationUserDefaultsCache(
                userDefaultsCache:coreDataLayer.getUserDefaultsCache()
            ),
            remoteConfigRepository: coreDataLayer.getRemoteConfigRepository()
        )
    }
}
