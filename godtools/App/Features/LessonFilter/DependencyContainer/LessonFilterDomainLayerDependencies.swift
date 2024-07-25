//
//  LessonFilterDomainLayerDependencies.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LessonFilterDomainLayerDependencies {
    
    private let dataLayer: LessonFilterDataLayerDependencies
    
    init(dataLayer: LessonFilterDataLayerDependencies) {
        self.dataLayer = dataLayer
    }
    
    func getSearchLessonFilterLanguagesUseCase() -> SearchLessonFilterLanguagesUseCase {
        
        return SearchLessonFilterLanguagesUseCase(searchLessonFilterLanguagesRepository: dataLayer.getSearchLessonFilterLanguagesRepositoryInterface())
    }
    
    func getStoreUserLessonFiltersUseCase() -> StoreUserLessonFiltersUseCase {
        
        return StoreUserLessonFiltersUseCase(storeUserLessonFiltersRepository: dataLayer.getStoreUserLessonFiltersRepositoryInterface())
    }
    
    func getUserLessonFiltersUseCase() -> GetUserLessonFiltersUseCase {
        return GetUserLessonFiltersUseCase(
            getUserLessonFiltersRepositoryInterface: dataLayer.getUserLessonFiltersRepositoryInterface()
        )
    }
    
    func getViewLessonFilterLanguagesUseCase() -> ViewLessonFilterLanguagesUseCase {
        
        return ViewLessonFilterLanguagesUseCase(
            getLessonFilterLanguagesRepository: dataLayer.getLessonFilterLanguagesRepositoryInterface(),
            getInterfaceStringsRepository: dataLayer.getLessonFilterLanguagesInterfaceStringsRepositoryInterface()
        )
    }
}
