//
//  GetTrainingTipCompletedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetTrainingTipCompletedUseCase: Sendable {
    
    private let repository: CompletedTrainingTipRepository
        
    init(repository: CompletedTrainingTipRepository) {
        
        self.repository = repository
    }
    
    func execute(tip: TrainingTipDomainModel) -> Bool {
        
        let id = TrainingTipId(
            trainingTipId: tip.trainingTipId,
            languageId: tip.languageId,
            resourceId: tip.resourceId
        )
        
        if repository.getCompletedTrainingTip(id: id) != nil {
            
            return true
            
        } else {
            
            return false
        }
    }
}
