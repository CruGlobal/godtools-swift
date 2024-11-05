//
//  GetTrainingTipCompletedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetTrainingTipCompletedUseCase {
    
    private let repository: CompletedTrainingTipRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CompletedTrainingTipRepository) {
        
        self.repository = repository
    }
    
    func hasTrainingTipBeenCompleted(tip: TrainingTipDomainModel) -> Bool {
        
        if repository.getCompletedTrainingTip(id: tip.id) != nil {
            
            return true
            
        } else {
            
            return false
        }
    }
}
