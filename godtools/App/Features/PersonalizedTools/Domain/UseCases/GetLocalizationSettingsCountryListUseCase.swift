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
    
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[LocalizationSettingsCountryDomainModel], Never> {
        
        // TODO: - remove this
        let countryDummyData = [
            LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "US", countryNameTranslatedInCurrentAppLanguage: "US"),
            LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Ngola", countryNameTranslatedInCurrentAppLanguage: "Angola"),
            LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Argentina", countryNameTranslatedInCurrentAppLanguage: "Argentina"),
            LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Hayastan", countryNameTranslatedInCurrentAppLanguage: "Armenia"),
            LocalizationSettingsCountryDomainModel(countryNameTranslatedInOwnLanguage: "Osterreich", countryNameTranslatedInCurrentAppLanguage: "Austria")
        ]
        
        return Just(countryDummyData)
            .eraseToAnyPublisher()
    }
}
