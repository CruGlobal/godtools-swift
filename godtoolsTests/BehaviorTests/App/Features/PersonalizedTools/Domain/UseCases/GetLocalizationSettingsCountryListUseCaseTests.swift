//
//  GetLocalizationSettingsCountryListUseCaseTests.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLocalizationSettingsCountryListUseCaseTests {

    struct PreferNotToSayTestArgument {
        let showsPreferNotToSay: Bool
        let expectedTotalCount: Int
        let expectedCountryCount: Int
    }

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: showsPreferNotToSay parameter is set
        Then: Should conditionally include "Prefer not to say" option at the beginning of the list
        """,
        arguments: [
            PreferNotToSayTestArgument(
                showsPreferNotToSay: true,
                expectedTotalCount: 4,
                expectedCountryCount: 3
            ),
            PreferNotToSayTestArgument(
                showsPreferNotToSay: false,
                expectedTotalCount: 3,
                expectedCountryCount: 3
            )
        ]
    )
    func shouldConditionallyIncludePreferNotToSayOption(argument: PreferNotToSayTestArgument) {

        let useCase = Self.createUseCase(countries: Self.createCountries())

        let countryListItems: [LocalizationSettingsCountryListItem] = useCase
            .execute(
                appLanguage: "en",
                showsPreferNotToSay: argument.showsPreferNotToSay
            )

        #expect(countryListItems.count == argument.expectedTotalCount)

        if argument.showsPreferNotToSay {
            if case .preferNotToSay(let preferNotToSay) = countryListItems.first {
                #expect(preferNotToSay.preferNotToSayText == "Prefer not to say")
            } else {
                Issue.record("First item should be preferNotToSay when enabled")
            }

            let countryItems = countryListItems.dropFirst()
            #expect(countryItems.count == argument.expectedCountryCount)

            for item in countryItems {
                if case .country = item {
                    continue
                } else {
                    Issue.record("Item should be a country")
                }
            }
        } else {
            #expect(countryListItems.count == argument.expectedCountryCount)

            for item in countryListItems {
                if case .country = item {
                    continue
                } else {
                    Issue.record("All items should be countries when preferNotToSay is disabled")
                }
            }
        }
    }

    struct LocalizationTestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedPreferNotToSayText: String
    }

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: Different app languages are set
        Then: "Prefer not to say" option should be localized correctly for each language
        """,
        arguments: [
            LocalizationTestArgument(appLanguage: "en", expectedPreferNotToSayText: "Prefer not to say"),
            LocalizationTestArgument(appLanguage: "es", expectedPreferNotToSayText: "Prefiero no decirlo"),
            LocalizationTestArgument(appLanguage: "fr", expectedPreferNotToSayText: "Je préfère ne pas le dire")
        ]
    )
    func shouldLocalizePreferNotToSayOptionBasedOnAppLanguage(argument: LocalizationTestArgument) {

        let useCase = Self.createUseCase(
            countries: Self.createCountries(),
            appLanguage: argument.appLanguage
        )

        let countryListItems: [LocalizationSettingsCountryListItem] = useCase
            .execute(
                appLanguage: argument.appLanguage,
                showsPreferNotToSay: true
            )

        if case .preferNotToSay(let preferNotToSay) = countryListItems.first {
            #expect(preferNotToSay.preferNotToSayText == argument.expectedPreferNotToSayText)
        } else {
            Issue.record("First item should be preferNotToSay")
        }
    }

    struct EmptyListTestArgument {
        let showsPreferNotToSay: Bool
        let expectedCount: Int
    }

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: Repository returns an empty list
        Then: Should return empty list or only "Prefer not to say" based on showsPreferNotToSay parameter
        """,
        arguments: [
            EmptyListTestArgument(showsPreferNotToSay: false, expectedCount: 0),
            EmptyListTestArgument(showsPreferNotToSay: true, expectedCount: 1)
        ]
    )
    func shouldHandleEmptyCountryList(argument: EmptyListTestArgument) {

        let useCase = Self.createUseCase(countries: [])

        let countryListItems: [LocalizationSettingsCountryListItem] = useCase
            .execute(
                appLanguage: "en",
                showsPreferNotToSay: argument.showsPreferNotToSay
            )

        #expect(countryListItems.count == argument.expectedCount)

        if argument.showsPreferNotToSay {
            if case .preferNotToSay(let preferNotToSay) = countryListItems.first {
                #expect(preferNotToSay.preferNotToSayText == "Prefer not to say")
            } else {
                Issue.record("First item should be preferNotToSay")
            }
        }
    }
}

// MARK: - Test Helpers

extension GetLocalizationSettingsCountryListUseCaseTests {

    private static func createUseCase(
        countries: [LocalizationSettingsCountryDataModel],
        appLanguage: AppLanguageDomainModel = "en"
    ) -> GetLocalizationSettingsCountryListUseCase {

        let repository = FakeLocalizationSettingsCountriesRepository(countries: countries)
        let localizationServices = FakeLocalizationServices(
            localizableStrings: [
                "en": ["localizationSettings.preferNotToSay": "Prefer not to say"],
                "es": ["localizationSettings.preferNotToSay": "Prefiero no decirlo"],
                "fr": ["localizationSettings.preferNotToSay": "Je préfère ne pas le dire"]
            ]
        )

        return GetLocalizationSettingsCountryListUseCase(
            countriesRepository: repository,
            localizationServices: localizationServices
        )
    }

    private static func createCountries() -> [LocalizationSettingsCountryDataModel] {
        return [
            LocalizationSettingsCountryDataModel(
                isoRegionCode: "US",
                countryNameTranslatedInOwnLanguage: "United States",
                countryNameTranslatedInCurrentAppLanguage: "United States"
            ),
            LocalizationSettingsCountryDataModel(
                isoRegionCode: "ES",
                countryNameTranslatedInOwnLanguage: "España",
                countryNameTranslatedInCurrentAppLanguage: "Spain"
            ),
            LocalizationSettingsCountryDataModel(
                isoRegionCode: "JP",
                countryNameTranslatedInOwnLanguage: "日本",
                countryNameTranslatedInCurrentAppLanguage: "Japan"
            )
        ]
    }
}

