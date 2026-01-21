//
//  UserLocalizationSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class UserLocalizationSettingsRepository {

    private let cache: RealmUserLocalizationSettingsCache

    init(cache: RealmUserLocalizationSettingsCache) {
        self.cache = cache
    }

    func setCountryPublisher(isoRegionCode: String) -> AnyPublisher<String, Never> {

        let dataModel = UserLocalizationSettingsDataModel(selectedCountryIsoRegionCode: isoRegionCode)
        cache.storeUserLocalizationSetting(dataModel: dataModel)

        return Just(isoRegionCode)
            .eraseToAnyPublisher()
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingsDataModel?, Never> {
        return cache.getUserLocalizationSettingPublisher()
    }
}
