//
//  PersonalizedToolsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class PersonalizedToolsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getLocalizationSettingsCountriesRepository() -> LocalizationSettingsCountriesRepositoryInterface {
        
        return LocalizationSettingsCountriesRepository()
    }

    func getPersonalizedToolsRepository() -> PersonalizedToolsRepository {

        let persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>

        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {

            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftPersonalizedToolsMapping()
            )
        }
        else {

            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmPersonalizedToolsMapping()
            )
        }

        let api = PersonalizedToolsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )

        let cache = PersonalizedToolsCache(
            persistence: persistence
        )

        return PersonalizedToolsRepository(
            api: api,
            cache: cache,
            syncInvalidatorPersistence: coreDataLayer.getUserDefaultsCache(),
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }

    func getUserLocalizationSettingsRepository() -> UserLocalizationSettingsRepository {
        
        let persistence: any Persistence<UserLocalizationSettingsDataModel, UserLocalizationSettingsDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserLocalizationSettingsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmUserLocalizationSettingsMapping()
            )
        }
        
        return UserLocalizationSettingsRepository(
            cache: UserLocalizationSettingsCache(
                persistence: persistence
            )
        )
    }
}
