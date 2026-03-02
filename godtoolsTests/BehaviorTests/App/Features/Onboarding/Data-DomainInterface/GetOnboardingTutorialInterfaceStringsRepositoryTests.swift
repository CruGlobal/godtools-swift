//
//  GetOnboardingTutorialInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetOnboardingTutorialInterfaceStringsRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the onboarding tutorial.
        When: The app language is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    func interfaceStringsAreTranslatedWhenAppLanguageChanges() async {
        
        let chooseLanguageButtonTitleKey: String = "onboardingTutorial.chooseLanguageButton.title"
        let beginButtonTitleKey: String = "onboardingTutorial.beginButton.title"
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                chooseLanguageButtonTitleKey: "Choose Language",
                beginButtonTitleKey: "Begin"
            ],
            LanguageCodeDomainModel.spanish.value: [
                chooseLanguageButtonTitleKey: "Elige lengua",
                beginButtonTitleKey: "Comenzar"
            ]
        ]
        
        let getOnboardingTutorialInterfaceStringsRepository =  GetOnboardingTutorialInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(
                localizableStrings: localizableStrings
            )
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: OnboardingTutorialStringsDomainModel?
        var spanishInterfaceStringsRef: OnboardingTutorialStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialStringsDomainModel, Never> in
                    
                    return getOnboardingTutorialInterfaceStringsRepository
                        .getStringsPublisher(appLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink { (interfaceStrings: OnboardingTutorialStringsDomainModel) in
                    
                    confirmation()
                    
                    sinkCount += 1
                    
                    if sinkCount == 1 {
                        
                        englishInterfaceStringsRef = interfaceStrings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if sinkCount == 2 {
                        
                        spanishInterfaceStringsRef = interfaceStrings
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishInterfaceStringsRef?.chooseAppLanguageButtonTitle == "Choose Language")
        #expect(englishInterfaceStringsRef?.beginTutorialButtonTitle == "Begin")
        
        #expect(spanishInterfaceStringsRef?.chooseAppLanguageButtonTitle == "Elige lengua")
        #expect(spanishInterfaceStringsRef?.beginTutorialButtonTitle == "Comenzar")
    }
}
