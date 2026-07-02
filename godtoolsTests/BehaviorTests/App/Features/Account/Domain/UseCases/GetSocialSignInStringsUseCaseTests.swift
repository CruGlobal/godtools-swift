//
//  GetSocialSignInStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetSocialSignInStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is signing in.
        When: The social sign in strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: SocialSignInStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.title == "\(argument.appLanguage):\(LocalizableStringKeys.signInTitle.key)")
        #expect(strings.subtitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInSubtitle.key)")
        #expect(strings.signInWithAppleActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInApple.key)")
        #expect(strings.signInWithFacebookActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInFacebook.key)")
        #expect(strings.signInWithGoogleActionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.signInGoogle.key)")
    }
}

extension GetSocialSignInStringsUseCaseTests {

    private func getUseCase() -> GetSocialSignInStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .signInTitle, .signInSubtitle, .signInApple, .signInFacebook, .signInGoogle
        ]

        return GetSocialSignInStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
