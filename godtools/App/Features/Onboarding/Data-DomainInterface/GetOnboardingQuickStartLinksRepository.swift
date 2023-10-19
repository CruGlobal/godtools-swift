//
//  GetOnboardingQuickStartLinksRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartLinksRepository: GetOnboardingQuickStartLinksRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getLinks(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> {
        
        let quickStartLinks: [OnboardingQuickStartLinkDomainModel] = [
            OnboardingQuickStartLinkDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.0.title"),
                actionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.0.button.title"),
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartArticles,
                linkType: .readOurArticles
            ),
            OnboardingQuickStartLinkDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.1.title"),
                actionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.1.button.title"),
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartLessons,
                linkType: .tryOurLessons
            ),
            OnboardingQuickStartLinkDomainModel(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.2.title"),
                actionTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.2.button.title"),
                analyticsEventActionName: AnalyticsConstants.ActionNames.onboardingQuickStartTools,
                linkType: .chooseOneOfOurTools
            )
        ]
        
        return Just(quickStartLinks)
            .eraseToAnyPublisher()
    }
}
