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

    private static let sharedUserId: String = "user"
    
    private let cache: UserLocalizationSettingsCache

    init(cache: UserLocalizationSettingsCache) {
        
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func storeUserCountry(isoRegionCode: String) async throws {

        let dataModel = UserLocalizationSettingsDataModel(
            id: Self.sharedUserId,
            createdAt: Date(),
            selectedCountryIsoRegionCode: isoRegionCode
        )
        
        try await cache.storeUserLocalizationSetting(dataModel: dataModel)
    }

    func getUserLocalizationSetting() -> UserLocalizationSettingsDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: Self.sharedUserId)
        }
        catch _ {
            return nil
        }
    }
}
