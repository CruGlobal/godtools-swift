//
//  GetCreatingToolScreenShareSessionTimedOutStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetCreatingToolScreenShareSessionTimedOutStringsUseCaseTests {

    @Test(
        """
        Given: Creating a tool screen share session has timed out.
        When: The timed out strings are requested.
        Then: The title and message describe the timeout.
        """,
        arguments: [
            LanguageCodeDomainModel.english.value,
            LanguageCodeDomainModel.spanish.value
        ]
    )
    func timedOutStringsAreReturned(appLanguage: AppLanguageDomainModel) {

        let useCase = getUseCase()

        let strings: CreatingToolScreenShareSessionTimedOutStringsDomainModel = useCase.execute(appLanguage: appLanguage)

        #expect(strings.title == "Timed Out")
        #expect(strings.message == "Timed out creating the session for tool screen share.")
    }
}

extension GetCreatingToolScreenShareSessionTimedOutStringsUseCaseTests {

    private func getUseCase() -> GetCreatingToolScreenShareSessionTimedOutStringsUseCase {

        let okKey: String = LocalizableStringKeys.ok.key

        let localizableStrings: [String: [String: String]] = [
            LanguageCodeDomainModel.english.value: [okKey: okKey],
            LanguageCodeDomainModel.spanish.value: [okKey: okKey]
        ]

        return GetCreatingToolScreenShareSessionTimedOutStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: localizableStrings)
        )
    }
}
