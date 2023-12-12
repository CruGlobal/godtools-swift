//
//  LessonsFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonsFeatureDomainLayerDependencies {
    
    private let dataLayer: LessonsFeatureDataLayerDependencies
    private let appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies
    
    init(dataLayer: LessonsFeatureDataLayerDependencies, appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.appLanguageFeatureDomainLayer = appLanguageFeatureDomainLayer
    }
    
    func getViewLessonsUseCase() -> ViewLessonsUseCase {
        return ViewLessonsUseCase(
            getInterfaceStringsRepository: dataLayer.getLessonsInterfaceStringsRepositoryInterface(),
            getLessonsListRepository: dataLayer.getLessonsListRepositoryInterface()
        )
    }
}
