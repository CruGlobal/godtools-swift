//
//  GetOnboardingTutorialStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetOnboardingTutorialStringsUseCaseTests {
    
    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedChooseLanguageButtonTitle: String
        let expectedBeginButtonTitle: String
    }
    
    @Test(
        """
        Given: User is viewing the onboarding tutorial.
        When: The app language is set.
        Then: The interface strings should be translated in the app language.
        """,
        arguments: [
            TestArgument(
                appLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedChooseLanguageButtonTitle: "Choose Language",
                expectedBeginButtonTitle: "Begin"
            ),
            TestArgument(
                appLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedChooseLanguageButtonTitle: "Elige lengua",
                expectedBeginButtonTitle: "Comenzar"
            )
        ]
    )
    func stringsAreTranslatedInAppLanguage(argument: TestArgument) async {
        
        let getOnboardingTutorialStringsUseCase = getOnboardingTutorialStringsUseCase()
        
        var stringsRef: OnboardingTutorialStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getOnboardingTutorialStringsUseCase
                .execute(appLanguage: argument.appLanguage)
                .sink { (strings: OnboardingTutorialStringsDomainModel) in
                    
                    stringsRef = strings
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }
        
        #expect(stringsRef?.chooseAppLanguageButtonTitle == argument.expectedChooseLanguageButtonTitle)
        #expect(stringsRef?.beginTutorialButtonTitle == argument.expectedBeginButtonTitle)
    }
}

extension GetOnboardingTutorialStringsUseCaseTests {
    
    private func getOnboardingTutorialStringsUseCase() -> GetOnboardingTutorialStringsUseCase {
        
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
        
        return GetOnboardingTutorialStringsUseCase(
            localizationServices: MockLocalizationServices(
                localizableStrings: localizableStrings
            )
        )
    }
}
