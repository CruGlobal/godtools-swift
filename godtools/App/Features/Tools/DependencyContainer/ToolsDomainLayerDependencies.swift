//
//  ToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolsDomainLayerDependencies {

    private let core: AppCoreDiContainer
    private let dataLayer: ToolsDataLayerDependencies
    private let personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies
    private let tutorialDomainLayer: TutorialDomainLayerDependencies

    init(core: AppCoreDiContainer, dataLayer: ToolsDataLayerDependencies, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies, tutorialDomainLayer: TutorialDomainLayerDependencies) {

        self.core = core
        self.dataLayer = dataLayer
        self.personalizedToolsDataLayer = personalizedToolsDataLayer
        self.tutorialDomainLayer = tutorialDomainLayer
    }
    
    func getDisableOptInOnboardingBannerUseCase() -> DisableOptInOnboardingBannerUseCase {
        return DisableOptInOnboardingBannerUseCase(
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getOptInOnboardingBannerEnabledUseCase() -> GetOptInOnboardingBannerEnabledUseCase {
        return GetOptInOnboardingBannerEnabledUseCase(
            getTutorialIsAvailableUseCase: tutorialDomainLayer.getTutorialIsAvailableUseCase(),
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }

    func getPullToRefreshToolsUseCase() -> PullToRefreshToolsUseCase {
        return PullToRefreshToolsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            personalizedToolsRepository: personalizedToolsDataLayer.getPersonalizedToolsRepository(),
            getLanguageElseAppLanguage: core.domainLayer.supporting.getLanguageElseAppLanguage()
        )
    }
    
    func getToolsStringsUseCase() -> GetToolsStringsUseCase {
        return GetToolsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getAllToolsUseCase() -> GetAllToolsUseCase {
        return GetAllToolsUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            getToolsListItems: core.domainLayer.supporting.getToolsListItems()
        )
    }
}
