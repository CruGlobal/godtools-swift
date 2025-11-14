//
//  LessonEvaluationFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationFeatureDomainLayerDependencies {
    
    private let dataLayer: LessonEvaluationFeatureDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: LessonEvaluationFeatureDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getCancelLessonEvaluationUseCase() -> CancelLessonEvaluationUseCase {
        return CancelLessonEvaluationUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository()
        )
    }
    
    func getDidChangeScaleForSpiritualConversationReadinessUseCase() -> DidChangeScaleForSpiritualConversationReadinessUseCase {
        return DidChangeScaleForSpiritualConversationReadinessUseCase(
            getTranslatedNumberCount: coreDataLayer.getTranslatedNumberCount()
        )
    }
    
    func getEvaluateLessonUseCase() -> EvaluateLessonUseCase {
        return EvaluateLessonUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository(),
            lessonFeedbackAnalytics: dataLayer.getLessonFeedbackAnalytics()
        )
    }
    
    func getLessonEvaluatedUseCase() -> GetLessonEvaluatedUseCase {
        return GetLessonEvaluatedUseCase(
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository()
        )
    }
    
    func getLessonEvaluationStringsUseCase() -> GetLessonEvaluationStringsUseCase {
        return GetLessonEvaluationStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
