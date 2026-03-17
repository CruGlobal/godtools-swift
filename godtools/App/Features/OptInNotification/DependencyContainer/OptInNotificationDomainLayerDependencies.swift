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
    private let getOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCase

    init(coreDataLayer: AppDataLayerDependencies, dataLayer: OptInNotificationDataLayerDependencies, getOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCase) {

        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.getOnboardingTutorialIsAvailableUseCase = getOnboardingTutorialIsAvailableUseCase
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
            getOnboardingTutorialIsAvailableUseCase: getOnboardingTutorialIsAvailableUseCase,
            optInNotificationRepository: dataLayer.getOptInNotificationRepository(),
            getNotificationStatus: getNotificationStatus()
        )
    }
}
