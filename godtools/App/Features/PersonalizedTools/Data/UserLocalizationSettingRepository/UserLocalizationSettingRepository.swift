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

    func setCountryPublisher(isoRegionCode: String) -> AnyPublisher<String, Never> {

        let dataModel = UserLocalizationSettingDataModel(selectedCountryIsoRegionCode: isoRegionCode)
        cache.storeUserLocalizationSetting(dataModel: dataModel)

        return Just(isoRegionCode)
            .eraseToAnyPublisher()
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingDataModel?, Never> {
        return cache.getUserLocalizationSettingPublisher()
    }
}
