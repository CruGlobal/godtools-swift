//
//  GetLocalizationSettingsCountryListTests.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetLocalizationSettingsCountryListTests {

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
    func shouldConditionallyIncludePreferNotToSayOption(argument: PreferNotToSayTestArgument) async {

        let useCase = Self.createUseCase(countries: Self.createMockCountries())

        var cancellables: Set<AnyCancellable> = Set()
        var countryListItems: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            useCase
                .execute(appLanguage: "en", showsPreferNotToSay: argument.showsPreferNotToSay)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    countryListItems = results
                }
                .store(in: &cancellables)
        }

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

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: Countries are retrieved from the repository
        Then: Should correctly map data models to domain models within country list items
        """
    )
    func shouldCorrectlyMapDataModelsToDomainModels() async {

        let useCase = Self.createUseCase(countries: Self.createMockCountries())

        var cancellables: Set<AnyCancellable> = Set()
        var countryListItems: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            useCase
                .execute(appLanguage: "en", showsPreferNotToSay: false)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    countryListItems = results
                }
                .store(in: &cancellables)
        }

        #expect(countryListItems.count == 3)

        if case .country(let country) = countryListItems[0] {
            #expect(country.isoRegionCode == "US")
            #expect(country.countryNameTranslatedInOwnLanguage == "United States")
            #expect(country.countryNameTranslatedInCurrentAppLanguage == "United States")
        } else {
            Issue.record("First item should be United States")
        }

        if case .country(let country) = countryListItems[1] {
            #expect(country.isoRegionCode == "ES")
            #expect(country.countryNameTranslatedInOwnLanguage == "España")
            #expect(country.countryNameTranslatedInCurrentAppLanguage == "Spain")
        } else {
            Issue.record("Second item should be Spain")
        }

        if case .country(let country) = countryListItems[2] {
            #expect(country.isoRegionCode == "JP")
            #expect(country.countryNameTranslatedInOwnLanguage == "日本")
            #expect(country.countryNameTranslatedInCurrentAppLanguage == "Japan")
        } else {
            Issue.record("Third item should be Japan")
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
    func shouldLocalizePreferNotToSayOptionBasedOnAppLanguage(argument: LocalizationTestArgument) async {

        let useCase = Self.createUseCase(
            countries: Self.createMockCountries(),
            appLanguage: argument.appLanguage
        )

        var cancellables: Set<AnyCancellable> = Set()
        var countryListItems: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            useCase
                .execute(appLanguage: argument.appLanguage, showsPreferNotToSay: true)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    countryListItems = results
                }
                .store(in: &cancellables)
        }

        if case .preferNotToSay(let preferNotToSay) = countryListItems.first {
            #expect(preferNotToSay.preferNotToSayText == argument.expectedPreferNotToSayText)
        } else {
            Issue.record("First item should be preferNotToSay")
        }
    }

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: Repository returns an empty list
        Then: Should return an empty list when showsPreferNotToSay is false
        """
    )
    func shouldReturnEmptyListWhenNoCountriesAndPreferNotToSayDisabled() async {

        let useCase = Self.createUseCase(countries: [])

        var cancellables: Set<AnyCancellable> = Set()
        var countryListItems: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            useCase
                .execute(appLanguage: "en", showsPreferNotToSay: false)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    countryListItems = results
                }
                .store(in: &cancellables)
        }

        #expect(countryListItems.isEmpty)
    }

    @Test(
        """
        Given: User is viewing the Localization Settings country list
        When: Repository returns an empty list and showsPreferNotToSay is true
        Then: Should return only the "Prefer not to say" option
        """
    )
    func shouldReturnOnlyPreferNotToSayWhenNoCountriesAndPreferNotToSayEnabled() async {

        let useCase = Self.createUseCase(countries: [])

        var cancellables: Set<AnyCancellable> = Set()
        var countryListItems: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            useCase
                .execute(appLanguage: "en", showsPreferNotToSay: true)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    countryListItems = results
                }
                .store(in: &cancellables)
        }

        #expect(countryListItems.count == 1)

        if case .preferNotToSay(let preferNotToSay) = countryListItems.first {
            #expect(preferNotToSay.preferNotToSayText == "Prefer not to say")
        } else {
            Issue.record("First item should be preferNotToSay")
        }
    }
}

// MARK: - Test Helpers

extension GetLocalizationSettingsCountryListTests {

    private static func createUseCase(
        countries: [LocalizationSettingsCountryDataModel],
        appLanguage: AppLanguageDomainModel = "en"
    ) -> GetLocalizationSettingsCountryListUseCase {

        let mockRepository = MockLocalizationSettingsCountriesRepository(countries: countries)
        let mockLocalizationServices = MockLocalizationServices(
            localizableStrings: [
                "en": ["localizationSettings.preferNotToSay": "Prefer not to say"],
                "es": ["localizationSettings.preferNotToSay": "Prefiero no decirlo"],
                "fr": ["localizationSettings.preferNotToSay": "Je préfère ne pas le dire"]
            ]
        )

        return GetLocalizationSettingsCountryListUseCase(
            countriesRepository: mockRepository,
            localizationServices: mockLocalizationServices
        )
    }

    private static func createMockCountries() -> [LocalizationSettingsCountryDataModel] {
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

