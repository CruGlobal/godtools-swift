//
//  GetSpiritualConversationReadinessScale.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSpiritualConversationReadinessScale: GetSpiritualConversationReadinessScaleInterface {
    
    private static let minScaleValue: Int = 1
    private static let maxScaleValue: Int = 10
    
    private let getTranslatedNumberCount: GetTranslatedNumberCount
    
    init(getTranslatedNumberCount: GetTranslatedNumberCount) {
        
        self.getTranslatedNumberCount = getTranslatedNumberCount
    }
    
    func getScalePublisher(scale: Int, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SpiritualConversationReadinessScaleDomainModel, Never> {
        
        let domainModel = SpiritualConversationReadinessScaleDomainModel(
            minScale: mapScaleToDomainModel(scale: GetSpiritualConversationReadinessScale.minScaleValue, translateInAppLanguage: translateInAppLanguage),
            maxScale: mapScaleToDomainModel(scale: GetSpiritualConversationReadinessScale.maxScaleValue, translateInAppLanguage: translateInAppLanguage),
            scale: mapScaleToDomainModel(scale: scale, translateInAppLanguage: translateInAppLanguage)
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
