//
//  GetTrainingTipCompletedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetTrainingTipCompletedUseCase {
    
    private let repository: CompletedTrainingTipRepository
        
    init(repository: CompletedTrainingTipRepository) {
        
        self.repository = repository
    }
    
    func execute(tip: TrainingTipDomainModel) -> Bool {
        
        if repository.getCompletedTrainingTip(id: tip.id) != nil {
            
            return true
            
        } else {
            
            return false
        }
    }
}
