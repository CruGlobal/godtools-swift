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
    
    private let getReadinessScale: GetSpiritualConversationReadinessScaleInterface
    
    init(getReadinessScale: GetSpiritualConversationReadinessScaleInterface) {
        
        self.getReadinessScale = getReadinessScale
    }
    
    func changeScalePublisher(scale: Int, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<SpiritualConversationReadinessScaleDomainModel, Never> {
        
        return getReadinessScale
            .getScalePublisher(scale: scale, translateInAppLanguage: translateInAppLanguage)
            .eraseToAnyPublisher()
    }
}
