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
        let stringsFileType: LocalizableStringsFileType = .strings
        
        let interfaceStrings = OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.chooseLanguageButton.title", fileType: stringsFileType),
            beginTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.beginButton.title", fileType: stringsFileType),
            nextTutorialPageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.nextButton.title", fileType: stringsFileType),
            readyForEveryConversationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.title", fileType: stringsFileType),
            readyForEveryConversationVideoLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.0.videoLink.title", fileType: stringsFileType),
            prepareForMomentsThatMatterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.title", fileType: stringsFileType),
            prepareForMomentsThatMatterMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.2.message", fileType: stringsFileType),
            talkWithGodAboutAnyoneTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.title", fileType: stringsFileType),
            talkWithGodAboutAnyoneMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.1.message", fileType: stringsFileType),
            helpSomeoneDiscoverJesusTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.title", fileType: stringsFileType),
            helpSomeoneDiscoverJesusMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "onboardingTutorial.3.message", fileType: stringsFileType)
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
