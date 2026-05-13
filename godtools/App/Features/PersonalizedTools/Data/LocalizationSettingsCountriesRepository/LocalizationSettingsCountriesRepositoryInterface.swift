//
//  LocalizationSettingsCountriesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 1/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol LocalizationSettingsCountriesRepositoryInterface {

    func getCountries(appLanguage: AppLanguageDomainModel) -> [LocalizationSettingsCountryDataModel]
}
