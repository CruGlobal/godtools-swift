//
//  GetDeferredDeepLinkModalStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetDeferredDeepLinkModalStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is presented the deferred deep link modal.
        When: The deferred deep link modal strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: DeferredDeepLinkModalStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.deferredDeepLinkModalTitle.key)")
        #expect(strings.message == "\(argument.appLanguage):\(LocalizableStringKeys.deferredDeepLinkModalMessage.key)")
    }
}

extension GetDeferredDeepLinkModalStringsUseCaseTests {

    private func getUseCase() -> GetDeferredDeepLinkModalStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [.deferredDeepLinkModalTitle, .deferredDeepLinkModalMessage]

        return GetDeferredDeepLinkModalStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
