//
//  GetLocalizationSettingsCountryListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLocalizationSettingsCountryListUseCase {
    
    private let countriesRepository: LocalizationSettingsCountriesRepositoryInterface

    init(countriesRepository: LocalizationSettingsCountriesRepositoryInterface) {
        self.countriesRepository = countriesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryDomainModel], Never> {

        return countriesRepository.getCountriesPublisher(appLanguage: appLanguage)
            .flatMap { (countries: [LocalizationSettingsCountryDataModel]) in

                let countryDomainModels = countries.map { country in

                    return LocalizationSettingsCountryDomainModel(
                        isoRegionCode: country.isoRegionCode,
                        countryNameTranslatedInOwnLanguage: country.countryNameTranslatedInOwnLanguage,
                        countryNameTranslatedInCurrentAppLanguage: country.countryNameTranslatedInCurrentAppLanguage
                    )
                }

                return Just(countryDomainModels)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
