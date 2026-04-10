//
//  PersonalizedToolsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class PersonalizedToolsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getLocalizationSettingsCountriesRepository() -> LocalizationSettingsCountriesRepositoryInterface {

        return LocalizationSettingsCountriesRepository()
    }

    func getPersonalizedLessonsRepository() -> PersonalizedLessonsRepository {

        let persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>

        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {

            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftPersonalizedLessonsMapping()
            )
        }
        else {

            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmPersonalizedLessonsMapping()
            )
        }

        let api = PersonalizedToolsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )

        let cache = PersonalizedLessonsCache(
            persistence: persistence
        )

        return PersonalizedLessonsRepository(
            persistence: persistence,
            api: api,
            cache: cache,
            syncInvalidatorPersistence: coreDataLayer.getUserDefaultsCache(),
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }

    func getPersonalizedToolsRepository() -> PersonalizedToolsRepository {

        let persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>

        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {

            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftPersonalizedToolsMapping()
            )
        }
        else {

            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmPersonalizedToolsMapping()
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
            persistence: persistence,
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
                dataModelMapping: SwiftUserLocalizationSettingsDataModelMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserLocalizationSettingsDataModelMapping()
            )
        }
        
        return UserLocalizationSettingsRepository(
            persistence: persistence,
            cache: UserLocalizationSettingsCache(persistence: persistence)
        )
    }
}
