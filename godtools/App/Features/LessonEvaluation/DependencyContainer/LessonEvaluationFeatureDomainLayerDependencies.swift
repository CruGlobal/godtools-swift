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
    
    func getCancelLessonEvaluation() -> CancelLessonEvaluation {
        return CancelLessonEvaluation(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository()
        )
    }
    
    func getDidChangeScaleForSpiritualConversationReadiness() -> DidChangeScaleForSpiritualConversationReadiness {
        return DidChangeScaleForSpiritualConversationReadiness(
            getTranslatedNumberCount: coreDataLayer.getTranslatedNumberCount()
        )
    }
    
    func getEvaluateLesson() -> EvaluateLesson {
        return EvaluateLesson(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository(),
            lessonFeedbackAnalytics: dataLayer.getLessonFeedbackAnalytics()
        )
    }
    
    func getLessonEvaluated() -> GetLessonEvaluated {
        return GetLessonEvaluated(
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository()
        )
    }
    
    func getLessonEvaluationStrings() -> GetLessonEvaluationStrings {
        return GetLessonEvaluationStrings(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
