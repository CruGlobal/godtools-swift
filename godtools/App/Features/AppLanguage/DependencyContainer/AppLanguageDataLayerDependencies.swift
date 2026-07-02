//
//  AppLanguageDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class AppLanguageDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getAppLanguagesPersistence() -> any Persistence<AppLanguageDataModel, AppLanguageCodable> {
        
        let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftAppLanguageMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmAppLanguageMapping()
            )
        }
        
        return persistence
    }
        
    func getAppLanguagesRepository(sync: AppLanguagesRepositorySyncInterface? = nil) -> AppLanguagesRepository {
        
        let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable> = getAppLanguagesPersistence()
        
        let api = AppLanguagesApi()
        
        let syncInvalidator = SyncInvalidator(
            id: String(describing: AppLanguagesRepositorySync.self),
            timeInterval: .minutes(minute: 15),
            persistence: coreDataLayer.getUserDefaultsCache()
        )
        
        let sync: AppLanguagesRepositorySyncInterface = sync ?? AppLanguagesRepositorySync(
            api: AppLanguagesApi(),
            persistence: persistence,
            syncInvalidator: syncInvalidator
        )
        
        return AppLanguagesRepository(
            api: api,
            cache: AppLanguagesCache(
                persistence: persistence
            ),
            sync: sync
        )
    }
    
    func getDownloadedLanguagesRepository() -> DownloadedLanguagesRepository {
            
        let persistence: any Persistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftDownloadedLanguageMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmDownloadedLanguageMapping()
            )
        }
        
        return DownloadedLanguagesRepository(
            cache: DownloadedLanguagesCache(
                persistence: persistence
            )
        )
    }
    
    func getToolLanguageDownloader() -> ToolLanguageDownloader {
        
        return ToolLanguageDownloader(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            toolDownloader: coreDataLayer.getToolDownloader(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
        )
    }
    
    func getUserAppLanguagePersistence() -> any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel> {
        
        let persistence: any Persistence<UserAppLanguageDataModel, UserAppLanguageDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserAppLanguageMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmUserAppLanguageMapping()
            )
        }
        
        return persistence
    }
    
    func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        
        let cache = UserAppLanguageCache(
            persistence: getUserAppLanguagePersistence()
        )
        
        return UserAppLanguageRepository(
            cache: cache
        )
    }
}
