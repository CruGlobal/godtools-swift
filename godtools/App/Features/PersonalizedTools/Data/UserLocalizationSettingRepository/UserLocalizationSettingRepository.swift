//
//  UserLocalizationSettingRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class UserLocalizationSettingRepository {

    private let cache: RealmUserLocalizationSettingCache

    init(cache: RealmUserLocalizationSettingCache) {
        self.cache = cache
    }

    func setCountryPublisher(countryName: String) -> AnyPublisher<String, Never> {

        let dataModel = UserLocalizationSettingDataModel(selectedCountryName: countryName)
        cache.storeUserLocalizationSetting(dataModel: dataModel)

        return Just(countryName)
            .eraseToAnyPublisher()
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingDataModel?, Never> {
        return cache.getUserLocalizationSettingPublisher()
    }
}
