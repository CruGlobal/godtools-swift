//
//  GetOnboardingQuickStartItemsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetOnboardingQuickStartItemsUseCase {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getOnboardingQuickStartItems() -> [OnboardingQuickStartItemDomainModel] {
        
        return [
            OnboardingQuickStartItemDomainModel(
                title: localizationServices.stringForSystemElseEnglish(key: "onboardingQuickStart.0.title"),
                actionTitle: localizationServices.stringForSystemElseEnglish(key:  "onboardingQuickStart.0.button.title"),
                actionFlowStep: .readArticlesTappedFromOnboardingQuickStart,
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartArticles
            ),
            OnboardingQuickStartItemDomainModel(
                title: localizationServices.stringForSystemElseEnglish(key: "onboardingQuickStart.1.title"),
                actionTitle: localizationServices.stringForSystemElseEnglish(key:  "onboardingQuickStart.1.button.title"),
                actionFlowStep: .tryLessonsTappedFromOnboardingQuickStart,
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartLessons
            ),
            OnboardingQuickStartItemDomainModel(
                title: localizationServices.stringForSystemElseEnglish(key: "onboardingQuickStart.2.title"),
                actionTitle: localizationServices.stringForSystemElseEnglish(key:  "onboardingQuickStart.2.button.title"),
                actionFlowStep: .chooseToolTappedFromOnboardingQuickStart,
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartTools
            ),
        ]
    }
}
