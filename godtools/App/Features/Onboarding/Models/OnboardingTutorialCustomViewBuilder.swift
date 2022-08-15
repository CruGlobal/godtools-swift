//
//  OnboardingTutorialCustomViewBuilder.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialCustomViewBuilder: CustomViewBuilderType {

    
    private weak var flowDelegate: FlowDelegate?
    
    private let deviceLanguage: DeviceLanguage
    private let localizationServices: LocalizationServices
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analyticsScreenName: String
    
    required init(flowDelegate: FlowDelegate, deviceLanguage: DeviceLanguage, localizationServices: LocalizationServices, tutorialVideoAnalytics: TutorialVideoAnalytics, analyticsScreenName: String) {
        
        self.flowDelegate = flowDelegate

        self.deviceLanguage = deviceLanguage
        self.localizationServices = localizationServices
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.analyticsScreenName = analyticsScreenName
    }

    func buildCustomView(customViewId: String) -> UIView? {

        if let onboardingFlowDelegate = flowDelegate, customViewId == "onboarding-0" {
            let viewModel = OnboardingTutorialIntroViewModel(flowDelegate: onboardingFlowDelegate, localizationServices: localizationServices, tutorialVideoAnalytics: tutorialVideoAnalytics, analyticsScreenName: analyticsScreenName)

            let view = OnboardingTutorialIntroView()

            view.configure(viewModel: viewModel)

            return view
        }

        return nil
    }
}
