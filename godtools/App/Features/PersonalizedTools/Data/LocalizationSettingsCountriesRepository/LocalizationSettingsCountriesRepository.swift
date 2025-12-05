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
    
    private let cache: RealmLocalizationSettingsCountriesCache
    
    init(cache: RealmLocalizationSettingsCountriesCache) {
        self.cache = cache
    }
    
    func getCountriesPublisher() -> AnyPublisher<[LocalizationSettingsCountryDataModel], Never> {
        
        return cache.getCountriesPublisher()
    }
}
