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
    
    func getLessonAvailabilityInAppLanguageUseCase() -> GetLessonAvailabilityInAppLanguageUseCase {
        
        return GetLessonAvailabilityInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: appLanguageFeatureDomainLayer.getCurrentAppLanguageUseCase(),
            getAppLanguageNameUseCase: appLanguageFeatureDomainLayer.getAppLanguageNameUseCase(),
            getInterfaceStringInAppLanguageUseCase: appLanguageFeatureDomainLayer.getInterfaceStringInAppLanguageUseCase(),
            getLessonIsAvailableInAppLanguageRepositoryInterface: dataLayer.getLessonIsAvailableInAppLanguageRepositoryInterface()
        )
    }
    
    func getLessonNameInAppLanguageUseCase() -> GetLessonNameInAppLanguageUseCase {
        
        return GetLessonNameInAppLanguageUseCase(
            getCurrentAppLanguageUseCase: appLanguageFeatureDomainLayer.getCurrentAppLanguageUseCase(),
            getLessonNameRepositoryInterface: dataLayer.getLessonNameRepositoryInterface()
        )
    }
    
    func getLessonsListUseCase() -> GetLessonsListUseCase {
        
        return GetLessonsListUseCase(
            getCurrentAppLanguageUseCase: appLanguageFeatureDomainLayer.getCurrentAppLanguageUseCase(),
            getLessonsListRepositoryInterface: dataLayer.getLessonsListRepositoryInterface(),
            getLessonNameInAppLanguageUseCase: getLessonNameInAppLanguageUseCase(),
            getLessonAvailabilityInAppLanguageUseCase: getLessonAvailabilityInAppLanguageUseCase()
        )
    }
}
