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

    func execute(appLanguage: AppLanguageDomainModel, showsPreferNotToSay: Bool) -> AnyPublisher<[LocalizationSettingsCountryListItem], Never> {

        return countriesRepository.getCountriesPublisher(appLanguage: appLanguage)
            .flatMap { (countries: [LocalizationSettingsCountryDataModel]) in

                let countryListItems: [LocalizationSettingsCountryListItem] = countries.map { country in

                    return .country(LocalizationSettingsCountryDomainModel(
                        isoRegionCode: country.isoRegionCode,
                        countryNameTranslatedInOwnLanguage: country.countryNameTranslatedInOwnLanguage,
                        countryNameTranslatedInCurrentAppLanguage: country.countryNameTranslatedInCurrentAppLanguage
                    ))
                }

                if showsPreferNotToSay {
                    let preferNotToSay = self.createPreferNotToSayOption(appLanguage: appLanguage)
                    return Just([preferNotToSay] + countryListItems)
                        .eraseToAnyPublisher()
                } else {
                    return Just(countryListItems)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func createPreferNotToSayOption(appLanguage: AppLanguageDomainModel) -> LocalizationSettingsCountryListItem {

        let preferNotToSayText = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: "localizationSettings.preferNotToSay"
        )

        return .preferNotToSay(LocalizationSettingsPreferNotToSayDomainModel(
            preferNotToSayText: preferNotToSayText
        ))
    }
}
