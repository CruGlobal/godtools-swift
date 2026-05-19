//
//  LessonFilterDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class LessonFilterDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LessonFilterDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LessonFilterDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getLessonFilterLangauge() -> GetLessonFilterLanguage {
        return GetLessonFilterLanguage(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: core.domainLayer.supporting.getTranslatedLanguageName(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
    
    func getLessonFilterLanguagesStringsUseCase() -> GetLessonFilterLanguagesStringsUseCase {
        
        return GetLessonFilterLanguagesStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getLessonFilterLanguagesUseCase() -> GetLessonFilterLanguagesUseCase {
        return GetLessonFilterLanguagesUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            languagesRepository: core.dataLayer.getLanguagesRepository(),
            getLessonFilterLangauge: getLessonFilterLangauge()
        )
    }
    
    func getUserLessonFiltersUseCase() -> GetUserLessonFiltersUseCase {
        return GetUserLessonFiltersUseCase(
            userLessonFiltersRepository: core.dataLayer.getUserLessonFiltersRepository(),
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
            userLessonFiltersRepository: core.dataLayer.getUserLessonFiltersRepository()
        )
    }
}
