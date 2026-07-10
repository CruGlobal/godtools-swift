//
//  GetAccountStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

struct GetAccountStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    private static let stringKeys: [LocalizableStringKeys] = [
        .accountNavTitle, .accountActivityTitle, .accountActivitySectionTitle,
        .accountBadgesSectionTitle, .accountGlobalActivityTitle, .accountActivityGlobalAnalyticsHeaderTitle
    ]

    @Test(
        """
        Given: User is viewing their account.
        When: The account strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func accountStringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: AccountStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.navTitle == "\(argument.appLanguage):\(LocalizableStringKeys.accountNavTitle.key)")
        #expect(strings.activityButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.accountActivityTitle.key)")
        #expect(strings.myActivitySectionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.accountActivitySectionTitle.key)")
        #expect(strings.badgesSectionTitle == "\(argument.appLanguage):\(LocalizableStringKeys.accountBadgesSectionTitle.key)")
        #expect(strings.globalActivityButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.accountGlobalActivityTitle.key)")
    }

    @Test(
        """
        Given: User is viewing their account.
        When: The global analytics title is requested for an app language.
        Then: The title is prefixed with the current year followed by the localized header title.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func globalAnalyticsTitleIsPrefixedWithTheCurrentYear(argument: TestArgument) async {

        let dateService: DateServiceInterface = FakeDateService()
        
        let useCase = getUseCase(dateService: dateService)

        let strings: AccountStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        let year: Int = dateService.getCurrentYear(options: CalendarOptions.defaultOptions) ?? 0

        let expectedTitle: String = "\(year) \(argument.appLanguage):\(LocalizableStringKeys.accountActivityGlobalAnalyticsHeaderTitle.key)"

        #expect(strings.globalAnalyticsTitle == expectedTitle)
    }
}

extension GetAccountStringsUseCaseTests {

    private func getUseCase(dateService: DateServiceInterface = FakeDateService()) -> GetAccountStringsUseCase {

        return GetAccountStringsUseCase(
            localizationServices: FakeLocalizationServices(
                localizableStrings: FakeLocalizationServices.getStrings(stringKeys: Self.stringKeys, languages: [.english, .spanish])
            ),
            dateService: dateService
        )
    }
}
