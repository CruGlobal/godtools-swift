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
    
    private func getAppLanguagesApi() -> AppLanguagesApi {
        return AppLanguagesApi()
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
    func getAppLanguagesRepository() -> AppLanguagesRepository {
                        
        return AppLanguagesRepository(
            api: getAppLanguagesApi(),
            cache: AppLanguagesCache(
                persistence: getAppLanguagesPersistence()
            )
        )
    }
    
    func getAppLanguagesRepositorySync() -> AppLanguagesRepositorySyncInterface {
        
        let syncInvalidator = SyncInvalidator(
            id: String(describing: AppLanguagesRepositorySync.self),
            timeInterval: .minutes(minute: 15),
            persistence: coreDataLayer.getUserDefaultsCache()
        )
        
        return AppLanguagesRepositorySync(
            api: getAppLanguagesApi(),
            persistence: getAppLanguagesPersistence(),
            syncInvalidator: syncInvalidator
        )
    }
    
    func getDownloadedLanguagesCache() -> DownloadedLanguagesCache {

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

        return DownloadedLanguagesCache(
            persistence: persistence
        )
    }

    func getDownloadedLanguagesRepository() -> DownloadedLanguagesRepository {

        return DownloadedLanguagesRepository(
            cache: getDownloadedLanguagesCache()
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
