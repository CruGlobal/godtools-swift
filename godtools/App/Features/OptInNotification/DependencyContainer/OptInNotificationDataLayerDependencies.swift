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
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface

    init(coreDataLayer: AppDataLayerDependencies, getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface) {

        self.coreDataLayer = coreDataLayer
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
    }

    // MARK: - Data Layer Classes

    func getOptInNotificationRepository() -> OptInNotificationRepository {
        return OptInNotificationRepository(
            cache: OptInNotificationUserDefaultsCache(
                userDefaultsCache:coreDataLayer.getUserDefaultsCache()
            ),
            remoteConfigRepository: coreDataLayer.getRemoteConfigRepository()
        )
    }

    // MARK: - Domain Interface

    func getOptInNotificationInterfaceStringsRepositoryInterface() -> GetOptInNotificationInterfaceStringsRepositoryInterface {
        return GetOptInNotificationInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }

    func getRequestNotificationPermission() -> GetRequestNotificationPermissionInterface {
        return GetRequestNotificationPermission()
    }

    func getCheckNotificationStatus() -> GetCheckNotificationStatusInterface {
        return GetCheckNotificationStatus()
    }
    
    func getShouldPromptForOptInNotification() -> ShouldPromptForOptInNotificationInterface {
        return ShouldPromptForOptInNotification(
            getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable,
            optInNotificationRepository: getOptInNotificationRepository(),
            checkNotificationStatus: getCheckNotificationStatus()
        )
    }
}
