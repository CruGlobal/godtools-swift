//
//  GetAppLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetAppLanguagesStringsUseCaseTests {
    
    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedNavTitle: String
    }
    
    @Test(
        """
        Given: User is viewing the app languages.
        When: The app language is set.
        Then: The interface strings should be translated in the app language.
        """,
        arguments: [
            TestArgument(
                appLanguage: LanguageCodeDomainModel.english.rawValue,
                expectedNavTitle: "App Language"
            ),
            TestArgument(
                appLanguage: LanguageCodeDomainModel.spanish.rawValue,
                expectedNavTitle: "Idioma de la aplicación"
            )
        ]
    )
    func stringsTranslateInAppLanguage(argument: TestArgument) async {
        
        let getAppLanguagesStringsUseCase = getAppLanguagesStringsUseCase()
        
        var stringsRef: AppLanguagesStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getAppLanguagesStringsUseCase
                .execute(appLanguage: argument.appLanguage)
                .sink { (strings: AppLanguagesStringsDomainModel) in
                    
                    stringsRef = strings
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }
        
        #expect(stringsRef?.navTitle == argument.expectedNavTitle)
    }
}

extension GetAppLanguagesStringsUseCaseTests {
    
    private func getAppLanguagesStringsUseCase() -> GetAppLanguagesStringsUseCase {
        
        let navTitleKey: String = "languageSettings.appLanguage.title"
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                navTitleKey: "App Language"
            ],
            LanguageCodeDomainModel.spanish.value: [
                navTitleKey: "Idioma de la aplicación"
            ]
        ]
        
        return GetAppLanguagesStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
        )
    }
}
