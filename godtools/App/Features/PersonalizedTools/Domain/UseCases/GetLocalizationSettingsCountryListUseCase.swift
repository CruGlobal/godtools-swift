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
    
    func execute(appLanguage: AppLanguageDomainModel, selectedCountryIsoRegionCode: String?, showsPreferNotToSay: Bool) -> [LocalizationSettingsCountryListItem] {

        let countries: [LocalizationSettingsCountryDataModel] = countriesRepository
            .getCountries(appLanguage: appLanguage)
        
        let countryListItems: [LocalizationSettingsCountryListItem] = countries.map { country in
            
            return .country(LocalizationSettingsCountryDomainModel(
                isoRegionCode: country.isoRegionCode,
                countryNameTranslatedInOwnLanguage: country.countryNameTranslatedInOwnLanguage,
                countryNameTranslatedInCurrentAppLanguage: country.countryNameTranslatedInCurrentAppLanguage
            ))
        }
        
        let listItems: [LocalizationSettingsCountryListItem]
        
        if showsPreferNotToSay {
            
            let preferNotToSay = createPreferNotToSayOption(
                appLanguage: appLanguage
            )
            
            listItems = [preferNotToSay] + countryListItems
        }
        else {
            
            listItems = countryListItems
        }
        
        return moveSelectedCountryToTopOfList(
            listItems: listItems,
            selectedCountryIsoRegionCode: selectedCountryIsoRegionCode
        )
    }

    private func moveSelectedCountryToTopOfList(listItems: [LocalizationSettingsCountryListItem], selectedCountryIsoRegionCode: String?) -> [LocalizationSettingsCountryListItem] {

        guard let selectedCountryIsoRegionCode = selectedCountryIsoRegionCode else {
            return listItems
        }

        guard let selectedIndex = listItems.firstIndex(where: { $0.isoRegionCode == selectedCountryIsoRegionCode }) else {
            return listItems
        }

        var listItemsWithSelectedCountryRemoved = listItems
        let selectedListItem = listItemsWithSelectedCountryRemoved.remove(at: selectedIndex)

        return [selectedListItem] + listItemsWithSelectedCountryRemoved
    }

    private func createPreferNotToSayOption(appLanguage: AppLanguageDomainModel) -> LocalizationSettingsCountryListItem {

        let preferNotToSayTextKey: String = "localizationSettings.preferNotToSay"

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                preferNotToSayTextKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let preferNotToSayText: String = strings[preferNotToSayTextKey] ?? ""

        return .preferNotToSay(LocalizationSettingsPreferNotToSayDomainModel(
            preferNotToSayText: preferNotToSayText
        ))
    }
}
