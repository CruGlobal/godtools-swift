//
//  DidChangeScaleForSpiritualConversationReadinessUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class DidChangeScaleForSpiritualConversationReadinessUseCase {
    
    private static let minScaleValue: Int = 1
    private static let maxScaleValue: Int = 10
    
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    func execute(scale: Int, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SpiritualConversationReadinessScaleDomainModel, Never> {
        
        let clampedScale: Int
        
        if scale < Self.minScaleValue {
            clampedScale = Self.minScaleValue
        }
        else if scale > Self.maxScaleValue {
            clampedScale = Self.maxScaleValue
        }
        else {
            clampedScale = scale
        }
        
        let domainModel = SpiritualConversationReadinessScaleDomainModel(
            minScale: mapScaleToDomainModel(scale: Self.minScaleValue, translateInAppLanguage: translateInAppLanguage),
            maxScale: mapScaleToDomainModel(scale: Self.maxScaleValue, translateInAppLanguage: translateInAppLanguage),
            scale: mapScaleToDomainModel(scale: clampedScale, translateInAppLanguage: translateInAppLanguage)
        )
        
        return Just(domainModel)
            .eraseToAnyPublisher()
    }
    
    private func mapScaleToDomainModel(scale: Int, translateInAppLanguage: AppLanguageDomainModel) -> LessonEvaluationScaleDomainModel {
        
        return LessonEvaluationScaleDomainModel(
            integerValue: scale,
            valueTranslatedInAppLanguage: getTranslatedNumberCount.getTranslatedCount(
                count: scale,
                translateInLanguage: translateInAppLanguage
            )
        )
    }
}
