//
//  OnboardingTutorialCustomViewBuilder.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialCustomViewBuilder: CustomViewBuilderType {

    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let localizationServices: LocalizationServices
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analyticsScreenName: String
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, tutorialVideoAnalytics: TutorialVideoAnalytics, analyticsScreenName: String) {
        
        self.flowDelegate = flowDelegate

        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.localizationServices = localizationServices
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.analyticsScreenName = analyticsScreenName
    }

    func buildCustomView(customViewId: String) -> UIView? {

        if let onboardingFlowDelegate = flowDelegate, customViewId == "onboarding-0" {
            
            let viewModel = OnboardingTutorialIntroViewModel(
                flowDelegate: onboardingFlowDelegate,
                getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
                getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
                localizationServices: localizationServices,
                tutorialVideoAnalytics: tutorialVideoAnalytics,
                analyticsScreenName: analyticsScreenName
            )

            let view = OnboardingTutorialIntroView()

            view.configure(viewModel: viewModel)

            return view
        }

        return nil
    }
}
