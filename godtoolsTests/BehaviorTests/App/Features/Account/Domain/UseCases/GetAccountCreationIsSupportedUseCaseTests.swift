//
//  GetAccountCreationIsSupportedUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetAccountCreationIsSupportedUseCaseTests {

    @Test(
        """
        Given: User's app language is a language that supports account creation.
        When: Checking if account creation is supported.
        Then: Account creation should be supported.
        """,
        arguments: [
            LanguageCodeDomainModel.english,
            LanguageCodeDomainModel.spanish
        ]
    )
    func accountCreationIsSupportedForSupportedAppLanguages(languageCode: LanguageCodeDomainModel) async {

        let useCase = getUseCase()

        let accountCreationIsSupported: AccountCreationIsSupportedDomainModel = await useCase.execute(appLanguage: languageCode.value)

        #expect(accountCreationIsSupported.isSupported == true)
    }

    @Test(
        """
        Given: User's app language is a region or script variant of a language that supports account creation.
        When: Checking if account creation is supported.
        Then: Account creation should be supported.
        """,
        arguments: [
            "en-US",
            "en-GB",
            "es-MX",
            "es-419"
        ]
    )
    func accountCreationIsSupportedForRegionVariantsOfSupportedAppLanguages(appLanguage: AppLanguageDomainModel) async {

        let useCase = getUseCase()

        let accountCreationIsSupported: AccountCreationIsSupportedDomainModel = await useCase.execute(appLanguage: appLanguage)

        #expect(accountCreationIsSupported.isSupported == true)
    }

    @Test(
        """
        Given: User's app language is a language that does not support account creation.
        When: Checking if account creation is supported.
        Then: Account creation should not be supported.
        """,
        arguments: [
            LanguageCodeDomainModel.afrikaans.value,
            LanguageCodeDomainModel.amharic.value,
            LanguageCodeDomainModel.arabic.value,
            LanguageCodeDomainModel.bangla.value,
            LanguageCodeDomainModel.chinese.value,
            LanguageCodeDomainModel.chineseSimplified.value,
            LanguageCodeDomainModel.chineseTraditional.value,
            LanguageCodeDomainModel.czech.value,
            LanguageCodeDomainModel.filipino.value,
            LanguageCodeDomainModel.finnish.value,
            LanguageCodeDomainModel.french.value,
            LanguageCodeDomainModel.german.value,
            LanguageCodeDomainModel.hausa.value,
            LanguageCodeDomainModel.hebrew.value,
            LanguageCodeDomainModel.hindi.value,
            LanguageCodeDomainModel.indonesian.value,
            LanguageCodeDomainModel.japanese.value,
            LanguageCodeDomainModel.korean.value,
            LanguageCodeDomainModel.latvian.value,
            LanguageCodeDomainModel.nepali.value,
            LanguageCodeDomainModel.oromo.value,
            LanguageCodeDomainModel.portuguese.value,
            LanguageCodeDomainModel.romanian.value,
            LanguageCodeDomainModel.russian.value,
            LanguageCodeDomainModel.swahili.value,
            LanguageCodeDomainModel.urdu.value,
            LanguageCodeDomainModel.vietnamese.value,
            "fr-CA",
            "pt-BR",
            "unknown_language_code"
        ]
    )
    func accountCreationIsNotSupportedForUnsupportedAppLanguages(appLanguage: AppLanguageDomainModel) async {

        let useCase = getUseCase()

        let accountCreationIsSupported: AccountCreationIsSupportedDomainModel = await useCase.execute(appLanguage: appLanguage)

        #expect(accountCreationIsSupported.isSupported == false)
    }
}

extension GetAccountCreationIsSupportedUseCaseTests {
    
    private func getUseCase() -> GetAccountCreationIsSupportedUseCase {
        return GetAccountCreationIsSupportedUseCase()
    }
}
