//
//  GetTrainingTipCompletedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetTrainingTipCompletedUseCase {
    
    private let repository: CompletedTrainingTipRepository
    private let deprecatedTipService: ViewedTrainingTipsService
    
    init(repository: CompletedTrainingTipRepository, service: ViewedTrainingTipsService) {
        
        self.repository = repository
        self.deprecatedTipService = service
    }
    
    func hasTrainingTipBeenCompleted(tip: TrainingTipDomainModel) -> Bool {
        
        if repository.getCompletedTrainingTip(id: tip.id) != nil {
            
            return true
            
        } else if deprecatedTipService.containsViewedTrainingTip(id: tip.id) {
            
            return true
            
        } else {
            
            return false
        }
    }
}
