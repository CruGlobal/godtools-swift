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
        
        var searchResults: [LocalizationSettingsCountryListItemDomainModel] = []
        
        await confirmation(expectedCount: 1) { confirmation in
        
            searchCountryList
                .execute(searchText: "e", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryListItemDomainModel]) in
                    
                    confirmation()
                    searchResults = results
                }
                .store(in: &cancellables)
        }
        
        let searchResultNames = searchResults.map { $0.countryNameTranslatedInCurrentAppLanguage }
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
        
        var searchResults: [LocalizationSettingsCountryListItemDomainModel] = []
        
        await confirmation(expectedCount: 1) { confirmation in
        
            searchCountryList
                .execute(searchText: "pan", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryListItemDomainModel]) in
                    
                    confirmation()
                    searchResults = results
                }
                .store(in: &cancellables)
        }
        
        let searchResultNames = searchResults.map { $0.countryNameTranslatedInCurrentAppLanguage }
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
    
    private static func getCountriesList() -> [LocalizationSettingsCountryListItemDomainModel] {
        
        let countriesList: [LocalizationSettingsCountryListItemDomainModel] = [
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "United States",
                countryNameTranslatedInCurrentAppLanguage: "United States"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "España",
                countryNameTranslatedInCurrentAppLanguage: "Spain"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "France",
                countryNameTranslatedInCurrentAppLanguage: "France"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "Deutschland",
                countryNameTranslatedInCurrentAppLanguage: "Germany"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "日本",
                countryNameTranslatedInCurrentAppLanguage: "Japan"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "Brasil",
                countryNameTranslatedInCurrentAppLanguage: "Brazil"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "대한민국",
                countryNameTranslatedInCurrentAppLanguage: "South Korea"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "Italia",
                countryNameTranslatedInCurrentAppLanguage: "Italy"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "中国",
                countryNameTranslatedInCurrentAppLanguage: "China"
              ),
              LocalizationSettingsCountryListItemDomainModel(
                isoRegionCode: "",
                countryNameTranslatedInOwnLanguage: "México",
                countryNameTranslatedInCurrentAppLanguage: "Mexico"
              )
          ]

        return countriesList
    }
}
