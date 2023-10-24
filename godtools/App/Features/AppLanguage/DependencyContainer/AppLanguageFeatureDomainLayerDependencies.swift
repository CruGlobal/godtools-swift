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
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getAppLanguagesListRepositoryInterface: dataLayer.getAppLanguagesListRepositoryInterface(),
            getUserPreferredAppLanguageRepositoryInterface: dataLayer.getUserPreferredAppLanguageRepositoryInterface()
        )
    }
    
    func getCurrentAppLanguageUseCase() -> GetCurrentAppLanguageUseCase {
        return GetCurrentAppLanguageUseCase(
            getAppLanguagesRepositoryInterface: dataLayer.getAppLanguagesRepositoryInterface(),
            getUserPreferredAppLanguageRepositoryInterface: dataLayer.getUserPreferredAppLanguageRepositoryInterface(),
            getDeviceAppLanguageRepositoryInterface: dataLayer.getDeviceAppLanguageRepositoryInterface()
        )
    }
    
    func getConfirmAppLanguageInterfaceStringsUseCase() -> GetConfirmAppLanguageInterfaceStringsUseCase {
        return GetConfirmAppLanguageInterfaceStringsUseCase(
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase(),
            getInterfaceStringRepositoryInterface: coreDataLayer.getInterfaceStringForLanguageRepositoryInterface(),
            localeLanguageName: coreDataLayer.getLocaleLanguageName()
        )
    }
    
    func getInterfaceLayoutDirectionUseCase() -> GetInterfaceLayoutDirectionUseCase {
        return GetInterfaceLayoutDirectionUseCase(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getAppLanguageRepositoryInterface: dataLayer.getAppLanguageRepositoryInterface(),
            getUserPreferredAppLanguageRepositoryInterface: dataLayer.getUserPreferredAppLanguageRepositoryInterface()
        )
    }
    
    func getInterfaceStringInAppLanguageUseCase() -> GetInterfaceStringInAppLanguageUseCase {
        return GetInterfaceStringInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getInterfaceStringRepositoryInterface: coreDataLayer.getInterfaceStringForLanguageRepositoryInterface()
        )
    }
    
    func getLanguageSettingsInterfaceStringsUseCase() -> GetLanguageSettingsInterfaceStringsUseCase {
        return GetLanguageSettingsInterfaceStringsUseCase(
            getLanguageSettingsInterfaceStringsRepositoryInterface: dataLayer.getLanguageSettingsInterfaceStringsRepositoryInterface()
        )
    }
    
    func getSearchAppLanguageInAppLanguagesListUseCase() -> SearchAppLanguageInAppLanguagesListUseCase {
        return SearchAppLanguageInAppLanguagesListUseCase(
            getAppLanguagesListUseCase: getAppLanguagesListUseCase()
        )
    }
    
    func getSetAppLanguageUseCase() -> SetAppLanguageUseCase {
        return SetAppLanguageUseCase(
            setUserPreferredAppLanguageRepositoryInterface: dataLayer.getSetUserPreferredAppLanguageRepositoryInterface()
        )
    }
}
