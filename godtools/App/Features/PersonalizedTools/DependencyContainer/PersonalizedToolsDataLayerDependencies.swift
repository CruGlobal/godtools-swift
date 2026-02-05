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
    
    func getPersonalizedToolsRepository() -> PersonalizedToolsRepository {

        let api = PersonalizedToolsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )

        return PersonalizedToolsRepository(
            api: api
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
