//
//  RealmLocalizationSettingsCountriesCache.swift
//  godtools
//
//  Created by Rachael Skeath on 12/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RealmLocalizationSettingsCountriesCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        self.realmDatabase = realmDatabase
    }
    
    func getCountriesPublisher() -> AnyPublisher<[LocalizationSettingsCountryDataModel], Never> {
        
        let countryDummyData = [
            LocalizationSettingsCountryDataModel(countryNameTranslatedInOwnLanguage: "US", countryNameTranslatedInCurrentAppLanguage: "US"),
            LocalizationSettingsCountryDataModel(countryNameTranslatedInOwnLanguage: "Ngola", countryNameTranslatedInCurrentAppLanguage: "Angola"),
            LocalizationSettingsCountryDataModel(countryNameTranslatedInOwnLanguage: "Argentina", countryNameTranslatedInCurrentAppLanguage: "Argentina"),
            LocalizationSettingsCountryDataModel(countryNameTranslatedInOwnLanguage: "Hayastan", countryNameTranslatedInCurrentAppLanguage: "Armenia"),
            LocalizationSettingsCountryDataModel(countryNameTranslatedInOwnLanguage: "Osterreich", countryNameTranslatedInCurrentAppLanguage: "Austria")
        ]
        
        return Just(countryDummyData)
            .eraseToAnyPublisher()
    }
}
