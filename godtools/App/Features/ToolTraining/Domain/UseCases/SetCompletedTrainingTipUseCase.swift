//
//  SetCompletedTrainingTipUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SetCompletedTrainingTipUseCase: Sendable {
    
    private let repository: CompletedTrainingTipRepository
    
    init(repository: CompletedTrainingTipRepository) {
        
        self.repository = repository
    }
    
    func execute(tip: TrainingTipDomainModel) async throws {
        
        let id = TrainingTipId(
            trainingTipId: tip.trainingTipId,
            languageId: tip.languageId,
            resourceId: tip.resourceId
        )
        
        try await repository.storeCompletedTrainingTip(id: id)
    }
}
