//
//  GetSocialCreateAccountStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetSocialCreateAccountStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is creating an account.
        When: The social create account strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: SocialCreateAccountStringsDomainModel = await useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.createAccountTitle.key)")
        #expect(strings.subtitle == "\(argument.appLanguage):\(LocalizableStringKeys.createAccountSubtitle.key)")
        #expect(strings.createWithAppleActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInApple.key)")
        #expect(strings.createWithFacebookActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInFacebook.key)")
        #expect(strings.createWithGoogleActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInGoogle.key)")
    }
}

extension GetSocialCreateAccountStringsUseCaseTests {

    private func getUseCase() -> GetSocialCreateAccountStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .createAccountTitle, .createAccountSubtitle, .signInApple, .signInFacebook, .signInGoogle
        ]

        return GetSocialCreateAccountStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
