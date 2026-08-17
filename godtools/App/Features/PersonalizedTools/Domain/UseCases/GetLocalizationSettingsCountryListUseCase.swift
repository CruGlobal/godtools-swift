//
//  GetLocalizationSettingsCountryListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetLocalizationSettingsCountryListUseCase: Sendable {

    private let countriesRepository: LocalizationSettingsCountriesRepositoryInterface
    private let localizationServices: LocalizationServicesInterface

    init(
        countriesRepository: LocalizationSettingsCountriesRepositoryInterface,
        localizationServices: LocalizationServicesInterface
    ) {
        self.countriesRepository = countriesRepository
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel, showsPreferNotToSay: Bool) -> [LocalizationSettingsCountryListItem] {

        let countries: [LocalizationSettingsCountryDataModel] = countriesRepository
            .getCountries(appLanguage: appLanguage)
        
        let countryListItems: [LocalizationSettingsCountryListItem] = countries.map { country in
            
            return .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: country.isoRegionCode,
                countryNameTranslatedInOwnLanguage: country.countryNameTranslatedInOwnLanguage,
                countryNameTranslatedInCurrentAppLanguage: country.countryNameTranslatedInCurrentAppLanguage
            ))
        }
        
        guard !showsPreferNotToSay else {
            
            let preferNotToSay = createPreferNotToSayOption(
                appLanguage: appLanguage
            )
            
            return [preferNotToSay] + countryListItems
        }
        
        return countryListItems
    }

    private func createPreferNotToSayOption(appLanguage: AppLanguageDomainModel) -> LocalizationSettingsCountryListItem {

        let preferNotToSayTextKey: String = "localizationSettings.preferNotToSay"

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                preferNotToSayTextKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        let preferNotToSayText: String = strings[preferNotToSayTextKey] ?? ""

        return .preferNotToSay(LocalizationSettingsPreferNotToSayDomainModel(
            preferNotToSayText: preferNotToSayText
        ))
    }
}
