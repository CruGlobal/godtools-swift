//
//  SearchCountriesInLocalizationSettingsCountriesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class SearchCountriesInLocalizationSettingsCountriesListUseCase {

    private let stringSearcher: StringSearcher

    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }

    func execute(searchText: String, in countriesList: [LocalizationSettingsCountryListItem]) -> AnyPublisher<[LocalizationSettingsCountryListItem], Never> {

        let searchResults = stringSearcher.search(for: searchText, in: countriesList)

        return Just(searchResults)
            .eraseToAnyPublisher()
    }
}
