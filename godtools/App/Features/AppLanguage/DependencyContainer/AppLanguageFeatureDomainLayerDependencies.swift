//
//  AppLanguageFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguageFeatureDomainLayerDependencies {
    
    private let dataLayer: AppLanguageFeatureDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: AppLanguageFeatureDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
            
    func getAppLanguagesListUseCase() -> GetAppLanguagesListUseCase {
        return GetAppLanguagesListUseCase(
            getAppLanguagesListRepository: dataLayer.getAppLanguagesListRepositoryInterface()
        )
    }
    
    func getCurrentAppLanguageUseCase() -> GetCurrentAppLanguageUseCase {
        return GetCurrentAppLanguageUseCase(
            getAppLanguageRepository: dataLayer.getAppLanguageRepository()
        )
    }
    
    func getDownloadToolLanguageUseCase() -> DownloadToolLanguageUseCase {
        return DownloadToolLanguageUseCase(
            downloadToolLanguageRepository: dataLayer.getDownloadToolLanguageRepositoryInterface()
        )
    }
    
    func getInterfaceLayoutDirectionUseCase() -> GetInterfaceLayoutDirectionUseCase {
        return GetInterfaceLayoutDirectionUseCase(
            getLayoutDirectionInterface: dataLayer.getAppInterfaceLayoutDirectionInterface()
        )
    }
    
    func getInterfaceStringInAppLanguageUseCase() -> GetInterfaceStringInAppLanguageUseCase {
        return GetInterfaceStringInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getInterfaceStringRepositoryInterface: coreDataLayer.getInterfaceStringForLanguageRepositoryInterface()
        )
    }
    
    func getRemoveDownloadedToolLanguageUseCase() -> RemoveDownloadedToolLanguageUseCase {
        return RemoveDownloadedToolLanguageUseCase(
            removeDownloadedToolLanguageRepository: dataLayer.getRemoveDownloadedToolLanguageRepositoryInterface()
        )
    }
    
    func getSearchAppLanguageInAppLanguagesListUseCase() -> SearchAppLanguageInAppLanguagesListUseCase {
        return SearchAppLanguageInAppLanguagesListUseCase(
            searchAppLanguageInAppLanguageListRepository: dataLayer.getSearchAppLanguageInAppLanguageListRepository()
        )
    }
    
    func getSearchLanguageInDownloadableLanguagesUseCase() -> SearchLanguageInDownloadableLanguagesUseCase {
        return SearchLanguageInDownloadableLanguagesUseCase(
            searchLanguageInDownloadableLanguagesRepository: dataLayer.getSearchLanguageInDownloadableLanguagesRepositoryInterface()
        )
    }
    
    func getSetAppLanguageUseCase() -> SetAppLanguageUseCase {
        return SetAppLanguageUseCase(
            setUserPreferredAppLanguageRepositoryInterface: dataLayer.getSetUserPreferredAppLanguageRepositoryInterface()
        )
    }
    
    func getStoreInitialAppLanguageUseCase() -> StoreInitialAppLanguageUseCase {
        return StoreInitialAppLanguageUseCase(
            storeInitialAppLanguage: dataLayer.getStoreInitialAppLanguage()
        )
    }
    
    func getViewAppLanguagesUseCase() -> ViewAppLanguagesUseCase {
        return ViewAppLanguagesUseCase(
            getInterfaceStringsRepository: dataLayer.getAppLanguagesInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewConfirmAppLanguageUseCase() -> ViewConfirmAppLanguageUseCase {
        return ViewConfirmAppLanguageUseCase(
            getConfirmAppLanguageInterfaceStringsRepository: dataLayer.getConfirmAppLanguageInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewDownloadableLanguagesUseCase() -> ViewDownloadableLanguagesUseCase {
        return ViewDownloadableLanguagesUseCase(
            getDownloadableLanguagesListRepository: dataLayer.getDownloadableLanguagesListRepositoryInterface(),
            getInterfaceStringsRepository: dataLayer.getDownloadableLanguagesInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewLanguageSettingsUseCase() -> ViewLanguageSettingsUseCase {
        return ViewLanguageSettingsUseCase(
            getInterfaceStringsRepository: dataLayer.getLanguageSettingsInterfaceStringsRepositoryInterface(), 
            getDownloadedLanguagesListRepositoryInterface: dataLayer.getDownloadedLanguagesListRepositoryInterface()
        )
    }
}
