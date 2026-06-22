//
//  AppLanguageDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class AppLanguageDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: AppLanguageDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: AppLanguageDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getAppLanguagesListUseCase() -> GetAppLanguagesListUseCase {
        return GetAppLanguagesListUseCase(
            appLanguagesRepository: dataLayer.getAppLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getAppLanguagesStringsUseCase() -> GetAppLanguagesStringsUseCase {
        return GetAppLanguagesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getConfirmAppLanguageStringsUseCase() -> GetConfirmAppLanguageStringsUseCase {
        return GetConfirmAppLanguageStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getCurrentAppLanguageUseCase() -> GetCurrentAppLanguageUseCase {
        return GetCurrentAppLanguageUseCase(
            userAppLanguageRepository: dataLayer.getUserAppLanguageRepository()
        )
    }
    
    func getDownloadableLanguagesListUseCase() -> GetDownloadableLanguagesListUseCase {
        return GetDownloadableLanguagesListUseCase(
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName(),
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
    
    func getDownloadableLanguagesStringsUseCase() -> GetDownloadableLanguagesStringsUseCase {
        return GetDownloadableLanguagesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getDownloadedLanguagesListUseCase() -> GetDownloadedLanguagesListUseCase {
        return GetDownloadedLanguagesListUseCase(
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: dataLayer.getDownloadedLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName()
        )
    }
    
    func getDownloadToolLanguageUseCase() -> DownloadToolLanguageUseCase {
        return DownloadToolLanguageUseCase(
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
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName(),
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
            userLessonFiltersRepository: core.dataLayer.getUserLessonFiltersRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository()
        )
    }
    
    func getStoreInitialAppLanguageUseCase() -> StoreInitialAppLanguageUseCase {
        return StoreInitialAppLanguageUseCase(
            deviceSystemLanguage: core.dataLayer.getDeviceSystemLanguage(),
            userAppLanguageRepository: dataLayer.getUserAppLanguageRepository(),
            appLanguagesRepository: dataLayer.getAppLanguagesRepository()
        )
    }
}
