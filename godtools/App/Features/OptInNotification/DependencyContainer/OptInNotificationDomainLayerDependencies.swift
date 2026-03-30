//
//  OptInNotificationDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationDomainLayerDependencies {

    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: OptInNotificationDataLayerDependencies
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable

    init(coreDataLayer: AppDataLayerDependencies, dataLayer: OptInNotificationDataLayerDependencies, getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable) {

        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
    }
    
    private func getNotificationStatus() -> GetNotificationStatus {
        return GetNotificationStatus()
    }
    
    func getCheckNotificationStatusUseCase() -> CheckNotificationStatusUseCase {
        return CheckNotificationStatusUseCase(
            getNotificationStatus: getNotificationStatus()
        )
    }
    
    func getOptInNotificationStringsUseCase() -> GetOptInNotificationStringsUseCase {
        return GetOptInNotificationStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getRequestNotificationPermissionUseCase() -> RequestNotificationPermissionUseCase {
        return RequestNotificationPermissionUseCase()
    }

    func getShouldPromptForOptInNotificationUseCase() -> ShouldPromptForOptInNotificationUseCase {
        return ShouldPromptForOptInNotificationUseCase(
            getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable,
            optInNotificationRepository: dataLayer.getOptInNotificationRepository(),
            getNotificationStatus: getNotificationStatus()
        )
    }
}
