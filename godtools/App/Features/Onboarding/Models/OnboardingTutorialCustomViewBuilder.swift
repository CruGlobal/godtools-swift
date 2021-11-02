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
    
    private let deviceLanguage: DeviceLanguageType
    private let localizationServices: LocalizationServices
    private let analyticsContainer: AnalyticsContainer
    private let analyticsScreenName: String
    
    required init(flowDelegate: FlowDelegate?, deviceLanguage: DeviceLanguageType, localizationServices: LocalizationServices, analyticsContainer: AnalyticsContainer, analyticsScreenName: String) {
        
        self.flowDelegate = flowDelegate

        self.deviceLanguage = deviceLanguage
        self.localizationServices = localizationServices
        self.analyticsContainer = analyticsContainer
        self.analyticsScreenName = analyticsScreenName
    }

    func buildCustomView(customViewId: String) -> UIView? {

        if customViewId == "onboarding-0" {
            let viewModel = OnboardingTutorialIntroViewModel(flowDelegate: flowDelegate, localizationServices: localizationServices, analyticsContainer: analyticsContainer, analyticsScreenName: analyticsScreenName)

            let view = OnboardingTutorialIntroView()

            view.configure(viewModel: viewModel)

            return view
        }

        return nil
    }
}
