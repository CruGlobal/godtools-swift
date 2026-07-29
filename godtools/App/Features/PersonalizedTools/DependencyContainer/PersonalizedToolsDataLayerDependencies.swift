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
    
    private func getPersonalizedToolsApi() -> PersonalizedToolsApi {
        return PersonalizedToolsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )
    }
    
    private func getPersonalizedToolsCache() -> PersonalizedToolsCache {
     
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

        return PersonalizedToolsCache(
            persistence: persistence
        )
    }

    func getPersonalizedToolsRepository() -> PersonalizedToolsRepository {

        return PersonalizedToolsRepository(
            api: getPersonalizedToolsApi(),
            cache: getPersonalizedToolsCache(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            sync: getPersonalizedToolsSync()
        )
    }
    
    func getPersonalizedToolsSync() -> PersonalizedToolsSync {
        return PersonalizedToolsSync(
            api: getPersonalizedToolsApi(),
            cache: getPersonalizedToolsCache(),
            syncInvalidatorPersistence: coreDataLayer.getUserDefaultsCache()
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
