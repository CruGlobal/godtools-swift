//
//  AppLanguageFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguageFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getAppLanguagesRepository() -> AppLanguagesRepository {
        return AppLanguagesRepository()
    }
    
    private func getUserAppLanguageRepository() -> UserAppLanguageRepository {
        return UserAppLanguageRepository(
            cache: RealmUserAppLanguageCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getAppLanguageNameRepositoryInterface() -> GetAppLanguageNameRepositoryInterface {
        return GetAppLanguageNameRepository(
            localeLanguageName: coreDataLayer.getLocaleLanguageName()
        )
    }
    
    func getAppLanguageRepositoryInterface() -> GetAppLanguageRepositoryInterface {
        return GetAppLanguageRepository(
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getAppLanguagesListRepositoryInterface() -> GetAppLanguagesListRepositoryInterface {
        return GetAppLanguagesListRepository(
            appLanguagesRepository: getAppLanguagesRepository()
        )
    }
    
    func getDeviceAppLanguageRepositoryInterface() -> GetDeviceAppLanguageRepositoryInterface {
        return GetDeviceAppLanguageRepository(
            deviceSystemLanguage: coreDataLayer.getDeviceSystemLanguage()
        )
    }
    
    func getSetUserPreferredAppLanguageRepositoryInterface() -> SetUserPreferredAppLanguageRepositoryInterface {
        return SetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
    
    func getUserPreferredAppLanguageRepositoryInterface() -> GetUserPreferredAppLanguageRepositoryInterface {
        return GetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: getUserAppLanguageRepository()
        )
    }
}
