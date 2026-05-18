//
//  LessonEvaluationDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LessonEvaluationDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LessonEvaluationDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LessonEvaluationDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getCancelLessonEvaluationUseCase() -> CancelLessonEvaluationUseCase {
        return CancelLessonEvaluationUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            lessonEvaluationRepository: dataLayer.getLessonEvaluationRepository()
        )
    }
    
    func getDidChangeScaleForSpiritualConversationReadinessUseCase() -> DidChangeScaleForSpiritualConversationReadinessUseCase {
        return DidChangeScaleForSpiritualConversationReadinessUseCase(
            getTranslatedNumberCount: core.domainLayer.supporting.getTranslatedNumberCount()
        )
    }
    
    func getEvaluateLessonUseCase() -> EvaluateLessonUseCase {
        return EvaluateLessonUseCase(
            resourcesRepository: core.dataLayer.getResourcesRepository(),
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
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
