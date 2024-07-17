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
            cancelLessonEvaluationRepositoryInterface: dataLayer.getCancelLessonEvaluationRepositoryInterface()
        )
    }
    
    func getDidChangeScaleForSpiritualConversationReadinessUseCase() -> DidChangeScaleForSpiritualConversationReadinessUseCase {
        return DidChangeScaleForSpiritualConversationReadinessUseCase(
            getReadinessScale: dataLayer.getSpiritualConversationReadinessScale()
        )
    }
    
    func getEvaluateLessonUseCase() -> EvaluateLessonUseCase {
        return EvaluateLessonUseCase(
            evaluateLessonRepositoryInterface: dataLayer.getEvaluateLessonRepositoryInterface()
        )
    }
    
    func getLessonEvaluatedUseCase() -> GetLessonEvaluatedUseCase {
        return GetLessonEvaluatedUseCase(
            getLessonEvaluatedRepositoryInterface: dataLayer.getLessonEvaluatedRepositoryInterface()
        )
    }
    
    func getLessonEvaluationInterfaceStringsUseCase() -> GetLessonEvaluationInterfaceStringsUseCase {
        return GetLessonEvaluationInterfaceStringsUseCase(
            getLessonEvaluationInterfaceStringsRepositoryInterface: dataLayer.getLessonEvaluationInterfaceStringsRepositoryInterface()
        )
    }
}
