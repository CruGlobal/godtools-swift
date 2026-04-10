//
//  MockLocalizationSettingsCountriesRepository.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 3/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class MockLocalizationSettingsCountriesRepository: LocalizationSettingsCountriesRepositoryInterface {

    private let countries: [LocalizationSettingsCountryDataModel]

    init(countries: [LocalizationSettingsCountryDataModel]) {
        self.countries = countries
    }

    func getCountriesPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryDataModel], Never> {
        return Just(countries)
            .eraseToAnyPublisher()
    }
}
