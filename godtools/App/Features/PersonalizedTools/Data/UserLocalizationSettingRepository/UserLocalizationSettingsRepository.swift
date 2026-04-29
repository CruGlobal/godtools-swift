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

final class UserLocalizationSettingsRepository {

    static let sharedUserId: String = "user"
    
    private let cache: UserLocalizationSettingsCache

    init(cache: UserLocalizationSettingsCache) {
        
        self.cache = cache
    }
    
    var persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel> {
        return cache.persistence
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        return persistence
            .observeCollectionChangesPublisher()
            .catch { (error: Error) in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func setCountryPublisher(isoRegionCode: String) -> AnyPublisher<UserLocalizationSettingsDataModel, Error> {

        let dataModel = UserLocalizationSettingsDataModel(
            id: Self.sharedUserId,
            createdAt: Date(),
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
