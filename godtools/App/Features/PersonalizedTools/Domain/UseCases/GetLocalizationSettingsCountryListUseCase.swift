//
//  GetLocalizationSettingsCountryListUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetLocalizationSettingsCountryListUseCase {

    private let countriesRepository: LocalizationSettingsCountriesRepositoryInterface
    private let localizationServices: LocalizationServicesInterface

    init(
        countriesRepository: LocalizationSettingsCountriesRepositoryInterface,
        localizationServices: LocalizationServicesInterface
    ) {
        self.countriesRepository = countriesRepository
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel, showsPreferNotToSay: Bool) async -> [LocalizationSettingsCountryListItem] {

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
            
            let preferNotToSay = await createPreferNotToSayOption(
                appLanguage: appLanguage
            )
            
            return [preferNotToSay] + countryListItems
        }
        
        return countryListItems
    }

    private func createPreferNotToSayOption(appLanguage: AppLanguageDomainModel) async -> LocalizationSettingsCountryListItem {

        let preferNotToSayText = await localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: "localizationSettings.preferNotToSay"
        )

        return .preferNotToSay(LocalizationSettingsPreferNotToSayDomainModel(
            preferNotToSayText: preferNotToSayText
        ))
    }
}
