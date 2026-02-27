//
//  SearchCountriesInLocalizationSettingsCountriesListTests.swift
//  godtools
//
//  Created by Rachael Skeath on 12/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchCountriesInLocalizationSettingsCountriesListTests {

    @Test(
        """
        Given: User is searching a country in the Localization Settings country list
        When: Inputing a single letter search text 'e'
        Then: Country names containing the letter 'e' in either translation of their country name-- translation by app language or the country's own language, ignoring case sensitivity.
        """
    )
    func searchingCountriesWithSingleLetterSearchText() async {

        let searchCountryList = Self.getSearchCountriesListUseCase()
        let countriesList = Self.getCountriesList()

        var cancellables: Set<AnyCancellable> = Set()

        var searchResults: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            searchCountryList
                .execute(searchText: "e", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    searchResults = results
                }
                .store(in: &cancellables)
        }

        let searchResultNames = searchResults.compactMap { item -> String? in
            if case .country(let country) = item { return country.countryNameTranslatedInCurrentAppLanguage }
            return nil
        }
        let expectedCountryNames = ["United States", "Spain", "France", "Germany", "South Korea", "Mexico"]

        #expect(searchResultNames.elementsEqual(expectedCountryNames))
    }

    @Test(
        """
        Given: User is searching a country in the Localization Settings country list
        When: Inputing a multi-letter search text 'pan'
        Then: Country names containing the letters 'pan' in either translation of their country name-- translation by app language or the country's own language, ignoring case sensitivity.
        """
    )
    func searchingCountriesWithMultiLetterSearchText() async {

        let searchCountryList = Self.getSearchCountriesListUseCase()
        let countriesList = Self.getCountriesList()

        var cancellables: Set<AnyCancellable> = Set()

        var searchResults: [LocalizationSettingsCountryListItem] = []

        await confirmation(expectedCount: 1) { confirmation in

            searchCountryList
                .execute(searchText: "pan", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryListItem]) in

                    confirmation()
                    searchResults = results
                }
                .store(in: &cancellables)
        }

        let searchResultNames = searchResults.compactMap { item -> String? in
            if case .country(let country) = item { return country.countryNameTranslatedInCurrentAppLanguage }
            return nil
        }
        let expectedCountryNames = ["Japan"]

        #expect(searchResultNames.elementsEqual(expectedCountryNames))
    }
}

extension SearchCountriesInLocalizationSettingsCountriesListTests {

    private static func getSearchCountriesListUseCase() -> SearchCountriesInLocalizationSettingsCountriesListUseCase {

        let searchCountriesUseCase = SearchCountriesInLocalizationSettingsCountriesListUseCase(stringSearcher: StringSearcher()
        )

        return searchCountriesUseCase
    }

    private static func getCountriesList() -> [LocalizationSettingsCountryListItem] {

        return [
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "US",
                countryNameTranslatedInOwnLanguage: "United States",
                countryNameTranslatedInCurrentAppLanguage: "United States"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "ES",
                countryNameTranslatedInOwnLanguage: "España",
                countryNameTranslatedInCurrentAppLanguage: "Spain"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "FR",
                countryNameTranslatedInOwnLanguage: "France",
                countryNameTranslatedInCurrentAppLanguage: "France"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "DE",
                countryNameTranslatedInOwnLanguage: "Deutschland",
                countryNameTranslatedInCurrentAppLanguage: "Germany"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "JP",
                countryNameTranslatedInOwnLanguage: "日本",
                countryNameTranslatedInCurrentAppLanguage: "Japan"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "BR",
                countryNameTranslatedInOwnLanguage: "Brasil",
                countryNameTranslatedInCurrentAppLanguage: "Brazil"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "KR",
                countryNameTranslatedInOwnLanguage: "대한민국",
                countryNameTranslatedInCurrentAppLanguage: "South Korea"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "IT",
                countryNameTranslatedInOwnLanguage: "Italia",
                countryNameTranslatedInCurrentAppLanguage: "Italy"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "CN",
                countryNameTranslatedInOwnLanguage: "中国",
                countryNameTranslatedInCurrentAppLanguage: "China"
            )),
            .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: "MX",
                countryNameTranslatedInOwnLanguage: "México",
                countryNameTranslatedInCurrentAppLanguage: "Mexico"
            )),
        ]
    }
}
