//
//  LessonFilterDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonFilterDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: LessonFilterDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: LessonFilterDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getLessonFilterLangauge() -> GetLessonFilterLanguage {
        return GetLessonFilterLanguage(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: coreDomainLayer.supporting.getTranslatedLanguageName(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    func getLessonFilterLanguagesStringsUseCase() -> GetLessonFilterLanguagesStringsUseCase {
        
        return GetLessonFilterLanguagesStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getLessonFilterLanguagesUseCase() -> GetLessonFilterLanguagesUseCase {
        return GetLessonFilterLanguagesUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            getLessonFilterLangauge: getLessonFilterLangauge()
        )
    }
    
    func getUserLessonFiltersUseCase() -> GetUserLessonFiltersUseCase {
        return GetUserLessonFiltersUseCase(
            userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguage: getLessonFilterLangauge()
        )
    }
    
    func getSearchLessonFilterLanguagesUseCase() -> SearchLessonFilterLanguagesUseCase {
        return SearchLessonFilterLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    func getStoreUserLessonFiltersUseCase() -> StoreUserLessonFiltersUseCase {
        return StoreUserLessonFiltersUseCase(
            userLessonFiltersRepository: coreDataLayer.getUserLessonFiltersRepository()
        )
    }
}
