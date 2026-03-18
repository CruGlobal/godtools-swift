//
//  AppLanguageFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguageFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: AppLanguageFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: AppLanguageFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getAppLanguagesListUseCase() -> GetAppLanguagesListUseCase {
        return GetAppLanguagesListUseCase(
            appLanguagesRepository: dataLayer.getAppLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getAppLanguagesStringsUseCase() -> GetAppLanguagesStringsUseCase {
        return GetAppLanguagesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getConfirmAppLanguageStringsUseCase() -> GetConfirmAppLanguageStringsUseCase {
        return GetConfirmAppLanguageStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getCurrentAppLanguageUseCase() -> GetCurrentAppLanguageUseCase {
        return GetCurrentAppLanguageUseCase(
            userAppLanguageRepository: dataLayer.getUserAppLanguageRepository()
        )
    }
    
    func getDownloadableLanguagesListUseCase() -> GetDownloadableLanguagesListUseCase {
        return GetDownloadableLanguagesListUseCase(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    func getDownloadableLanguagesStringsUseCase() -> GetDownloadableLanguagesStringsUseCase {
        return GetDownloadableLanguagesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDownloadedLanguagesListUseCase() -> GetDownloadedLanguagesListUseCase {
        return GetDownloadedLanguagesListUseCase(
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getDownloadToolLanguageUseCase() -> DownloadToolLanguageUseCase {
        return DownloadToolLanguageUseCase(
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            toolLanguageDownloader: dataLayer.getToolLanguageDownloader()
        )
    }

    func getInterfaceLayoutDirectionUseCase() -> GetInterfaceLayoutDirectionUseCase {
        return GetInterfaceLayoutDirectionUseCase(
            appLanguagesRepository: dataLayer.getAppLanguagesRepository()
        )
    }
    
    func getLanguageSettingsStringsUseCase() -> GetLanguageSettingsStringsUseCase {
        return GetLanguageSettingsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName(),
            appLanguagesRepository: dataLayer.getAppLanguagesRepository()
        )
    }
    
    func getRemoveDownloadedToolLanguageUseCase() -> RemoveDownloadedToolLanguageUseCase {
        return RemoveDownloadedToolLanguageUseCase(
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository()
        )
    }
    
    func getSearchAppLanguageInAppLanguagesListUseCase() -> SearchAppLanguageInAppLanguagesListUseCase {
        return SearchAppLanguageInAppLanguagesListUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSearchLanguageInDownloadableLanguagesUseCase() -> SearchLanguageInDownloadableLanguagesUseCase {
        return SearchLanguageInDownloadableLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getSetAppLanguageUseCase() -> SetAppLanguageUseCase {
        return SetAppLanguageUseCase(
            userAppLanguageRepository: dataLayer.getUserAppLanguageRepository(),
            userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository()
        )
    }
    
    func getStoreInitialAppLanguageUseCase() -> StoreInitialAppLanguageUseCase {
        return StoreInitialAppLanguageUseCase(
            deviceSystemLanguage: coreDataLayer.getDeviceSystemLanguage(),
            userAppLanguageRepository: dataLayer.getUserAppLanguageRepository(),
            appLanguagesRepository: dataLayer.getAppLanguagesRepository()
        )
    }
}
