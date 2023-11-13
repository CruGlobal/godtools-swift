//
//  GetOnboardingTutorialInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingTutorialInterfaceStringsRepository: GetOnboardingTutorialInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.chooseLanguageButton.title"),
            beginTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.beginButton.title"),
            nextTutorialPageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.nextButton.title"),
            readyForEveryConversationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.0.title"),
            readyForEveryConversationVideoLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.0.videoLink.title"),
            prepareForMomentsThatMatterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.2.title"),
            prepareForMomentsThatMatterMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.2.message"),
            talkWithGodAboutAnyoneTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.1.title"),
            talkWithGodAboutAnyoneMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.1.message"),
            helpSomeoneDiscoverJesusTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.3.title"),
            helpSomeoneDiscoverJesusMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.3.message")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
