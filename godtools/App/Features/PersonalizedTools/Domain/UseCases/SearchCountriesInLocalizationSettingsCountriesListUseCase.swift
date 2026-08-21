//
//  SearchCountriesInLocalizationSettingsCountriesListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class SearchCountriesInLocalizationSettingsCountriesListUseCase: Sendable {

    private let stringSearcher: StringSearcher

    init(stringSearcher: StringSearcher) {
        self.stringSearcher = stringSearcher
    }

    func execute(
        searchText: String,
        countriesList: [LocalizationSettingsCountryListItem]
    ) -> [LocalizationSettingsCountryListItem] {

        return stringSearcher.search(for: searchText, in: countriesList)
    }
}
