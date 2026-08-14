//
//  FakeLocalizationSettingsCountriesRepository.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

final class FakeLocalizationSettingsCountriesRepository: LocalizationSettingsCountriesRepositoryInterface {

    private let countries: [LocalizationSettingsCountryDataModel]

    init(countries: [LocalizationSettingsCountryDataModel]) {
        self.countries = countries
    }
    
    func getCountries(appLanguage: AppLanguageDomainModel) -> [LocalizationSettingsCountryDataModel] {
        return countries
    }
}
