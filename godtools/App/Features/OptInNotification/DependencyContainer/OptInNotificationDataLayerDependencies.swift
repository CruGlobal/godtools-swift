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

    // MARK: - Data Layer Classes

    func getOptInNotificationRepository() -> OptInNotificationRepository {
        return OptInNotificationRepository(
            cache: OptInNotificationsUserDefaultsCache(sharedUserDefaultsCache:coreDataLayer.getSharedUserDefaultsCache())
        )
    }
    
    func getLaunchCountRepository() -> LaunchCountRepository {
        return coreDataLayer.getSharedLaunchCountRepository()
    }

    // MARK: - Domain Interface

    func getOptInNotificationInterfaceStringsRepositoryInterface() -> GetOptInNotificationInterfaceStringsRepositoryInterface {
        return GetOptInNotificationInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }

    func getOptInDialogInterfaceStringsRepositoryInterface() -> GetOptInDialogInterfaceStringsRepositoryInterface {
        return GetOptInDialogInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }

    func getRequestNotificationPermission() -> GetRequestNotificationPermissionInterface {
        return GetRequestNotificationPermission()
    }

    func getCheckNotificationStatus() -> GetCheckNotificationStatusInterface {
        return GetCheckNotificationStatus()
    }
}
