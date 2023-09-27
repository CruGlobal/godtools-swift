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
    
    init(dataLayer: AppLanguageFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getAppLanguageNameInAppLanguageUseCase() -> GetAppLanguageNameInAppLanguageUseCase {
        return GetAppLanguageNameInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getAppLanguageNameRepositoryInterface: dataLayer.getAppLanguageNameRepositoryInterface()
        )
    }
    
    func getAppLanguageNameUseCase() -> GetAppLanguageNameUseCase {
        return GetAppLanguageNameUseCase(
            getAppLanguageNameRepositoryInterface: dataLayer.getAppLanguageNameRepositoryInterface()
        )
    }
    
    func getAppLanguagesListUseCase() -> GetAppLanguagesListUseCase {
        return GetAppLanguagesListUseCase(
            getAppLanguagesListRepositoryInterface: dataLayer.getAppLanguagesListRepositoryInterface(),
            getAppLanguageNameUseCase: getAppLanguageNameUseCase(),
            getAppLanguageNameInAppLanguageUseCase: getAppLanguageNameInAppLanguageUseCase()
        )
    }
    
    func getCurrentAppLanguageUseCase() -> GetCurrentAppLanguageUseCase {
        return GetCurrentAppLanguageUseCase(
            getAppLanguagesListRepositoryInterface: dataLayer.getAppLanguagesListRepositoryInterface(),
            getUserPreferredAppLanguageRepositoryInterface: dataLayer.getUserPreferredAppLanguageRepositoryInterface(),
            getDeviceAppLanguageRepositoryInterface: dataLayer.getDeviceAppLanguageRepositoryInterface()
        )
    }
    
    func getInterfaceStringInAppLanguageUseCase() -> GetInterfaceStringInAppLanguageUseCase {
        return GetInterfaceStringInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase(),
            getInterfaceStringRepositoryInterface: dataLayer.getInterfaceStringForLanguageRepositoryInterface()
        )
    }
}
