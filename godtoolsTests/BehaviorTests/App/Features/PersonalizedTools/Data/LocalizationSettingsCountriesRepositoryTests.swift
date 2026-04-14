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

        var countries: [LocalizationSettingsCountryDataModel] = []
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            repository
                .getCountriesPublisher(appLanguage: argument.appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
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

        var countries: [LocalizationSettingsCountryDataModel] = []
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
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

        var countries: [LocalizationSettingsCountryDataModel] = []
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
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

        var countries: [LocalizationSettingsCountryDataModel] = []
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        for country in countries {
            #expect(!country.countryNameTranslatedInCurrentAppLanguage.isEmpty)
            #expect(!country.countryNameTranslatedInOwnLanguage.isEmpty)
            #expect(!country.isoRegionCode.isEmpty)
        }
    }

    struct AuthoritativeEndonymTestArgument {
        let isoCode: String
        let expectedEndonym: String
    }

    @Test(
        """
        Given: User is viewing the localization settings countries list
        When: Countries are requested
        Then: Countries should use the authoritative endonyms from the static mapping
        """,
        arguments: [
            AuthoritativeEndonymTestArgument(isoCode: "AT", expectedEndonym: "Österreich"),
            AuthoritativeEndonymTestArgument(isoCode: "AG", expectedEndonym: "Antigua & Barbuda"),
            AuthoritativeEndonymTestArgument(isoCode: "CW", expectedEndonym: "Curaçao"),
            AuthoritativeEndonymTestArgument(isoCode: "SA", expectedEndonym: "المملكة العربية السعودية"),
            AuthoritativeEndonymTestArgument(isoCode: "UA", expectedEndonym: "Україна"),
            AuthoritativeEndonymTestArgument(isoCode: "TW", expectedEndonym: "台灣"),
            AuthoritativeEndonymTestArgument(isoCode: "NZ", expectedEndonym: "Aotearoa"),
            AuthoritativeEndonymTestArgument(isoCode: "TR", expectedEndonym: "Türkiye"),
            AuthoritativeEndonymTestArgument(isoCode: "CF", expectedEndonym: "Ködörösêse tî Bêafrîka")
        ]
    )
    func countriesUseAuthoritativeEndonymsFromStaticMapping(argument: AuthoritativeEndonymTestArgument) async {

        let repository = LocalizationSettingsCountriesRepository()
        let appLanguage: AppLanguageDomainModel = "en"

        var countries: [LocalizationSettingsCountryDataModel] = []
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            repository
                .getCountriesPublisher(appLanguage: appLanguage)
                .sink { (result: [LocalizationSettingsCountryDataModel]) in

                    countries = result
                    
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        let country = countries.first(where: { $0.isoRegionCode == argument.isoCode })
        #expect(country?.countryNameTranslatedInOwnLanguage == argument.expectedEndonym)
        #expect(country?.countryNameTranslatedInOwnLanguage == CountryEndonyms.mapping[argument.isoCode])
    }
}
