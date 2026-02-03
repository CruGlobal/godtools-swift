//
//  PersonalizedToolsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class PersonalizedToolsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getLocalizationSettingsCountriesRepository() -> LocalizationSettingsCountriesRepositoryInterface {

        return LocalizationSettingsCountriesRepository()
    }

    func getPersonalizedLessonsCache() -> PersonalizedLessonsCache {

        let personalizedLessonsSync = RealmPersonalizedLessonsCacheSync(
            realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase()
        )

        return PersonalizedLessonsCache(
            realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase(),
            personalizedLessonsSync: personalizedLessonsSync
        )
    }

    func getPersonalizedLessonsRepository() -> PersonalizedLessonsRepository {

        let api = PersonalizedToolsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )

        return PersonalizedLessonsRepository(
            api: api,
            cache: getPersonalizedLessonsCache()
        )
    }

    func getUserLocalizationSettingsRepository() -> UserLocalizationSettingsRepository {

        return UserLocalizationSettingsRepository(
            cache: RealmUserLocalizationSettingsCache(realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase())
        )
    }
}
