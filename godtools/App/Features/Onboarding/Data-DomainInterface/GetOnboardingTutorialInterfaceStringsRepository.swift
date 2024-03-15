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
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        let localeId: String = appLanguage
        let fileType: LocalizableStringsFileType = .strings
        
        let interfaceStrings = OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.chooseLanguageButton.title", fileType: fileType),
            beginTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.beginButton.title", fileType: fileType),
            nextTutorialPageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.nextButton.title", fileType: fileType),
            readyForEveryConversationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.title", fileType: fileType),
            readyForEveryConversationVideoLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.videoLink.title", fileType: fileType),
            prepareForMomentsThatMatterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.title", fileType: fileType),
            prepareForMomentsThatMatterMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.message", fileType: fileType),
            talkWithGodAboutAnyoneTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.title", fileType: fileType),
            talkWithGodAboutAnyoneMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.message", fileType: fileType),
            helpSomeoneDiscoverJesusTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.title", fileType: fileType),
            helpSomeoneDiscoverJesusMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.message", fileType: fileType)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
