//
//  SetCompletedTrainingTipUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SetCompletedTrainingTipUseCase {
    
    private let repository: CompletedTrainingTipRepository
    
    init(repository: CompletedTrainingTipRepository) {
        
        self.repository = repository
    }
    
    func execute(tip: TrainingTipDomainModel) async throws {
        
        try await repository.storeCompletedTrainingTip(
            id: tip.trainingTipId,
            resourceId: tip.resourceId,
            languageId: tip.languageId
        )
    }
}
