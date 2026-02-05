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
    private let localizationServices: LocalizationServicesInterface

    init(countriesRepository: LocalizationSettingsCountriesRepositoryInterface, localizationServices: LocalizationServicesInterface) {
        self.countriesRepository = countriesRepository
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryListItemDomainModel], Never> {

        return countriesRepository.getCountriesPublisher(appLanguage: appLanguage)
            .flatMap { (countries: [LocalizationSettingsCountryDataModel]) in

                let preferNotToSay = self.createPreferNotToSayOption(appLanguage: appLanguage)

                let countryDomainModels = countries.map { country in

                    return LocalizationSettingsCountryListItemDomainModel(
                        isoRegionCode: country.isoRegionCode,
                        countryNameTranslatedInOwnLanguage: country.countryNameTranslatedInOwnLanguage,
                        countryNameTranslatedInCurrentAppLanguage: country.countryNameTranslatedInCurrentAppLanguage
                    )
                }

                return Just([preferNotToSay] + countryDomainModels)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func createPreferNotToSayOption(appLanguage: AppLanguageDomainModel) -> LocalizationSettingsCountryListItemDomainModel {

        let preferNotToSayText = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: "localizationSettings.preferNotToSay"
        )

        return LocalizationSettingsCountryListItemDomainModel(
            isoRegionCode: "",
            countryNameTranslatedInOwnLanguage: preferNotToSayText,
            countryNameTranslatedInCurrentAppLanguage: ""
        )
    }
}
