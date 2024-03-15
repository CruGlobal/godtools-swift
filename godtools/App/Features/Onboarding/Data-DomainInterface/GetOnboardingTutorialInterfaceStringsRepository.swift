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
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        
        let interfaceStrings = OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.chooseLanguageButton.title"),
            beginTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.beginButton.title"),
            nextTutorialPageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.nextButton.title"),
            endTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.getStartedButton.title"),
            readyForEveryConversationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.title"),
            readyForEveryConversationVideoLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.videoLink.title"),
            prepareForMomentsThatMatterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.title"),
            prepareForMomentsThatMatterMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.message"),
            talkWithGodAboutAnyoneTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.title"),
            talkWithGodAboutAnyoneMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.message"),
            helpSomeoneDiscoverJesusTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.title"),
            helpSomeoneDiscoverJesusMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.message")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
