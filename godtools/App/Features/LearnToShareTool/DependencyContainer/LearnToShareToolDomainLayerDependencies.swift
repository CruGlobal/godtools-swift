//
//  LearnToShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolDomainLayerDependencies: Sendable {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LearnToShareToolDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LearnToShareToolDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getLearnToShareToolTutorialIsAvailableUseCase() -> LearnToShareToolTutorialIsAvailableUseCaseInterface {
        
        guard core.dataLayer.getAppBuild().target != .uiTests else {
            return UITestsLearnToShareToolTutorialIsAvailableUseCase()
        }
        
        return LearnToShareToolTutorialIsAvailableUseCase(
            toolTrainingTipsOnboardingViewsRepository: dataLayer.getToolTrainingTipsOnboardingViewsRepository(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName()
        )
    }
    
    func getLearnToShareToolStringsUseCase() -> GetLearnToShareToolStringsUseCase {
        return GetLearnToShareToolStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getLearnToShareToolTutorialUseCase() -> GetLearnToShareToolTutorialUseCase {
        return GetLearnToShareToolTutorialUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getViewedLearnToShareToolTutorialUseCase() -> ViewedLearnToShareToolTutorialUseCase {
        return ViewedLearnToShareToolTutorialUseCase(
            toolTrainingTipsOnboardingViewsRepository: dataLayer.getToolTrainingTipsOnboardingViewsRepository(),
            getTranslatedToolName: core.domainLayer.supporting.getTranslatedToolName()
        )
    }
}
