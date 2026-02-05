//
//  UserLocalizationSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 1/15/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

class UserLocalizationSettingsRepository: RepositorySync<UserLocalizationSettingsDataModel, NoExternalDataFetch<UserLocalizationSettingsDataModel>> {

    static let sharedUserId: String = "user"
    
    private let cache: UserLocalizationSettingsCache

    init(persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>, cache: UserLocalizationSettingsCache) {
        
        self.cache = cache
        
        super.init(
            externalDataFetch: NoExternalDataFetch<UserLocalizationSettingsDataModel>(),
            persistence: persistence
        )
    }

    func setCountryPublisher(isoRegionCode: String) -> AnyPublisher<UserLocalizationSettingsDataModel, Error> {

        let dataModel = UserLocalizationSettingsDataModel(
            id: Self.sharedUserId,
            selectedCountryIsoRegionCode: isoRegionCode
        )
        
        return cache.storeUserLocalizationSetting(dataModel: dataModel)
            .map { _ in
                return dataModel
            }
            .eraseToAnyPublisher()
    }

    func getUserLocalizationSettingPublisher() -> AnyPublisher<UserLocalizationSettingsDataModel?, Error> {
        
        return cache.getUserLocalizationSettingPublisher(id: Self.sharedUserId)
    }
}
