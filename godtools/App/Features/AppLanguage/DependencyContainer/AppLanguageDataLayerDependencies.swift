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
        
    func getAppLanguagesRepository(sync: AppLanguagesRepositorySyncInterface? = nil) -> AppLanguagesRepository {
        
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
        
        let persistence: any Persistence<ToolLanguageDownloadDataModel, ToolLanguageDownloadDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftToolLanguageDownloadMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmToolLanguageDownloadMapping()
            )
        }
        
        let cache = ToolLanguageDownloadCache(
            persistence: persistence
        )
        
        return ToolLanguageDownloader(
            cache: cache,
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            toolDownloader: coreDataLayer.getToolDownloader(),
            downloadedLanguagesRepository: getDownloadedLanguagesRepository()
        )
    }
    
    func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        
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
        
        let cache = UserAppLanguageCache(persistence: persistence)
        
        return UserAppLanguageRepository(
            cache: cache
        )
    }
}
