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
        
        var searchResults: [LocalizationSettingsCountryDomainModel] = []
        
        await confirmation(expectedCount: 1) { confirmation in
        
            searchCountryList
                .execute(searchText: "e", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryDomainModel]) in
                    
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
        
        var searchResults: [LocalizationSettingsCountryDomainModel] = []
        
        await confirmation(expectedCount: 1) { confirmation in
        
            searchCountryList
                .execute(searchText: "pan", in: countriesList)
                .sink { (results: [LocalizationSettingsCountryDomainModel]) in
                    
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
    
    private static func getCountriesList() -> [LocalizationSettingsCountryDomainModel] {
        
        let countriesList: [LocalizationSettingsCountryDomainModel] = [
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "United States",
                  countryNameTranslatedInCurrentAppLanguage: "United States"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "España",
                  countryNameTranslatedInCurrentAppLanguage: "Spain"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "France",
                  countryNameTranslatedInCurrentAppLanguage: "France"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "Deutschland",
                  countryNameTranslatedInCurrentAppLanguage: "Germany"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "日本",
                  countryNameTranslatedInCurrentAppLanguage: "Japan"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "Brasil",
                  countryNameTranslatedInCurrentAppLanguage: "Brazil"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "대한민국",
                  countryNameTranslatedInCurrentAppLanguage: "South Korea"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "Italia",
                  countryNameTranslatedInCurrentAppLanguage: "Italy"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "中国",
                  countryNameTranslatedInCurrentAppLanguage: "China"
              ),
              LocalizationSettingsCountryDomainModel(
                  countryNameTranslatedInOwnLanguage: "México",
                  countryNameTranslatedInCurrentAppLanguage: "Mexico"
              )
          ]

        return countriesList
    }
}
