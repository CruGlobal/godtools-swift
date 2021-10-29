//
//  OnboardingTutorialCustomViewBuilder.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialCustomViewBuilder: CustomViewBuilderType {

    private let deviceLanguage: DeviceLanguageType
    private let localizationServices: LocalizationServices

    required init(deviceLanguage: DeviceLanguageType, localizationServices: LocalizationServices) {

        self.deviceLanguage = deviceLanguage
        self.localizationServices = localizationServices
    }

    func buildCustomView(customViewId: String) -> UIView? {

        if customViewId == "onboarding-0" {
            let viewModel = OnboardingTutorialIntroViewModel(localizationServices: localizationServices)

            let view = OnboardingTutorialIntroView()

            view.configure(viewModel: viewModel)

            return view
        }

        return nil
    }
}
