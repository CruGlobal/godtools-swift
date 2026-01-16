//
//  LocalizationSettingsCountriesRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class LocalizationSettingsCountriesRepository {

    init() {
    }

    func getCountriesPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryDataModel], Never> {

        let appLocale = Locale(identifier: appLanguage)

        let countries = Locale.Region.isoRegions.compactMap { region -> LocalizationSettingsCountryDataModel? in

            let regionLocale = findLocaleId(for: region)

            guard let nameInAppLanguage = appLocale.localizedString(forRegionCode: region.identifier),
                  let nameInOwnLanguage = regionLocale.localizedString(forRegionCode: region.identifier)
            else {
                return nil
            }

            return LocalizationSettingsCountryDataModel(
                isoRegionCode: region.identifier,
                countryNameTranslatedInOwnLanguage: nameInOwnLanguage,
                countryNameTranslatedInCurrentAppLanguage: nameInAppLanguage
            )
        }
        .sorted { $0.countryNameTranslatedInCurrentAppLanguage < $1.countryNameTranslatedInCurrentAppLanguage }

        return Just(countries)
            .eraseToAnyPublisher()
    }
    
    private func findLocaleId(for region: Locale.Region) -> Locale {
        
        let regionAndLanguageLocaleId = Locale.availableIdentifiers.first(where: { identifier in
            
            return identifier.hasSuffix("_\(region.identifier)") || identifier == region.identifier.lowercased()
        })
        
        return Locale(identifier: regionAndLanguageLocaleId ?? region.identifier)
    }
}
