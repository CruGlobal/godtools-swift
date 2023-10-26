//
//  LessonEvaluationFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getLessonEvaluationRepository() -> LessonEvaluationRepository {
        return LessonEvaluationRepository(
            cache: LessonEvaluationRealmCache(realmDatabase: coreDataLayer.getSharedRealmDatabase())
        )
    }
    
    private func getLessonFeedbackAnalytics() -> LessonFeedbackAnalytics {
        return LessonFeedbackAnalytics(
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    // MARK: - Domain Interface
    
    func getCancelLessonEvaluationRepositoryInterface() -> CancelLessonEvaluationRepositoryInterface {
        return CancelLessonEvaluationRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: getLessonEvaluationRepository()
        )
    }
    
    func getEvaluateLessonRepositoryInterface() -> EvaluateLessonRepositoryInterface {
        return EvaluateLessonRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: getLessonEvaluationRepository(),
            lessonFeedbackAnalytics: getLessonFeedbackAnalytics()
        )
    }
    
    func getLessonEvaluatedRepositoryInterface() -> GetLessonEvaluatedRepositoryInterface {
        return GetLessonEvaluatedRepository(
            lessonEvaluationRepository: getLessonEvaluationRepository()
        )
    }
    
    func getLessonEvaluationInterfaceStringsRepositoryInterface() -> GetLessonEvaluationInterfaceStringsRepositoryInterface {
        return GetLessonEvaluationInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
