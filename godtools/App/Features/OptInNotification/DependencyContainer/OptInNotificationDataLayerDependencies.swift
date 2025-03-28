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

    func getLastPromptedOptInNotificationRepository()
        -> LastPromptedOptInNotificationRepository
    {
        return LastPromptedOptInNotificationRepository(
            cache: LastPromptedOptInNotificationUserDefaultsCache(
                sharedUserDefaultsCache:
                    coreDataLayer.getSharedUserDefaultsCache())
        )
    }

    // MARK: - Domain Interface

    func getOptInNotificationInterfaceStringsRepositoryInterface()
        -> GetOptInNotificationInterfaceStringsRepositoryInterface
    {
        return GetOptInNotificationInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }

    func getOptInDialogInterfaceStringsRepositoryInterface()
        -> GetOptInDialogInterfaceStringsRepositoryInterface
    {
        return GetOptInDialogInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
