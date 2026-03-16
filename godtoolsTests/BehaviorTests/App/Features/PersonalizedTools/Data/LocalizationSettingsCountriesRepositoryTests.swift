//
//  LocalizationSettingsCountriesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct LocalizationSettingsCountriesRepositoryTests {

    struct TranslationTestArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedUSName: String
        let expectedJapanName: String
        let expectedGermanyName: String
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: App language is set
        Then: Countries should be returned with names translated in the app language and consistently in their primary language
        """,
        arguments: [
            TranslationTestArgument(
                appLanguage: "en",
                expectedUSName: "United States",
                expectedJapanName: "Japan",
                expectedGermanyName: "Germany"
            ),
            TranslationTestArgument(
                appLanguage: "es",
                expectedUSName: "Estados Unidos",
                expectedJapanName: "Japón",
                expectedGermanyName: "Alemania"
            ),
            TranslationTestArgument(
                appLanguage: "fr",
                expectedUSName: "États-Unis",
                expectedJapanName: "Japon",
                expectedGermanyName: "Allemagne"
            )
        ]
    )
    func countriesAreReturnedWithCorrectTranslations(argument: TranslationTestArgument) async {

        let repository = LocalizationSettingsCountriesRepository()

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: argument.appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        #expect(!countries.isEmpty)

        let unitedStates = countries.first(where: { $0.isoRegionCode == "US" })
        #expect(unitedStates?.countryNameTranslatedInCurrentAppLanguage == argument.expectedUSName)
        #expect(unitedStates?.countryNameTranslatedInOwnLanguage == "United States")

        let japan = countries.first(where: { $0.isoRegionCode == "JP" })
        #expect(japan?.countryNameTranslatedInCurrentAppLanguage == argument.expectedJapanName)
        #expect(japan?.countryNameTranslatedInOwnLanguage == "日本")

        let germany = countries.first(where: { $0.isoRegionCode == "DE" })
        #expect(germany?.countryNameTranslatedInCurrentAppLanguage == argument.expectedGermanyName)
        #expect(germany?.countryNameTranslatedInOwnLanguage == "Deutschland")
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: App language is set
        Then: Countries should be sorted alphabetically by their name in the app language
        """
    )
    func countriesAreSortedAlphabeticallyByAppLanguage() async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        let countryNames = countries.map { $0.countryNameTranslatedInCurrentAppLanguage }
        let sortedNames = countryNames.sorted()

        #expect(countryNames == sortedNames)
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: Repository filters regions
        Then: Only valid 2-letter ISO country codes should be included
        """
    )
    func onlyValidTwoLetterIsoCountryCodesAreReturned() async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        for country in countries {
            let code = country.isoRegionCode
            #expect(code.count == 2)
            #expect(code.allSatisfy { $0.isUppercase && $0.isLetter })
        }
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: Requesting countries
        Then: All countries should have non-empty translations in both app language and own language
        """
    )
    func allCountriesHaveNonEmptyTranslations() async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        for country in countries {
            #expect(!country.countryNameTranslatedInCurrentAppLanguage.isEmpty)
            #expect(!country.countryNameTranslatedInOwnLanguage.isEmpty)
            #expect(!country.isoRegionCode.isEmpty)
        }
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: Countries with exact language-region code matches are requested
        Then: Countries should return their native language translations correctly
        """
    )
    func countriesWithExactLanguageRegionMatchesReturnNativeTranslations() async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        let france = countries.first(where: { $0.isoRegionCode == "FR" })
        #expect(france?.countryNameTranslatedInOwnLanguage == "France")

        let spain = countries.first(where: { $0.isoRegionCode == "ES" })
        #expect(spain?.countryNameTranslatedInOwnLanguage == "España")

        let italy = countries.first(where: { $0.isoRegionCode == "IT" })
        #expect(italy?.countryNameTranslatedInOwnLanguage == "Italia")

        let russia = countries.first(where: { $0.isoRegionCode == "RU" })
        #expect(russia?.countryNameTranslatedInOwnLanguage == "Россия")

        let southKorea = countries.first(where: { $0.isoRegionCode == "KR" })
        #expect(southKorea?.countryNameTranslatedInOwnLanguage == "대한민국")

        let poland = countries.first(where: { $0.isoRegionCode == "PL" })
        #expect(poland?.countryNameTranslatedInOwnLanguage == "Polska")
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: Countries where language code differs from region code are requested
        Then: Countries should still return their primary language translations correctly
        """
    )
    func countriesWithDifferentLanguageRegionCodesReturnPrimaryLanguageTranslations() async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var cancellables: Set<AnyCancellable> = Set()
        var countries: [LocalizationSettingsCountryDataModel] = []

        await confirmation(expectedCount: 1) { confirmation in

            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    confirmation()
                }
                .store(in: &cancellables)
        }

        let austria = countries.first(where: { $0.isoRegionCode == "AT" })
        #expect(austria?.countryNameTranslatedInOwnLanguage == "Österreich")

        let unitedKingdom = countries.first(where: { $0.isoRegionCode == "GB" })
        #expect(unitedKingdom?.countryNameTranslatedInOwnLanguage == "United Kingdom")

        let australia = countries.first(where: { $0.isoRegionCode == "AU" })
        #expect(australia?.countryNameTranslatedInOwnLanguage == "Australia")

        let brazil = countries.first(where: { $0.isoRegionCode == "BR" })
        #expect(brazil?.countryNameTranslatedInOwnLanguage == "Brasil")

        let mexico = countries.first(where: { $0.isoRegionCode == "MX" })
        #expect(mexico?.countryNameTranslatedInOwnLanguage == "México")

        let china = countries.first(where: { $0.isoRegionCode == "CN" })
        #expect(china?.countryNameTranslatedInOwnLanguage == "中国大陆")
    }
}
