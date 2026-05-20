//
//  DidChangeScaleForSpiritualConversationReadinessUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class DidChangeScaleForSpiritualConversationReadinessUseCase {
    
    private static let minScaleValue: Int = 1
    private static let maxScaleValue: Int = 10
    
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    func execute(scale: Int, appLanguage: AppLanguageDomainModel) -> SpiritualConversationReadinessScaleDomainModel {
        
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
            minScale: mapScaleToDomainModel(scale: Self.minScaleValue, translateInAppLanguage: appLanguage),
            maxScale: mapScaleToDomainModel(scale: Self.maxScaleValue, translateInAppLanguage: appLanguage),
            scale: mapScaleToDomainModel(scale: clampedScale, translateInAppLanguage: appLanguage)
        )
        
        return domainModel
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
