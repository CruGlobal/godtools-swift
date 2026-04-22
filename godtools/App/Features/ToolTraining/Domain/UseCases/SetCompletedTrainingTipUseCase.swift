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
    
    func execute(tip: TrainingTipDomainModel) -> AnyPublisher<TrainingTipDomainModel, Error>  {
        
        let trainingTipDataModel = CompletedTrainingTipDataModel(
            id: tip.trainingTipId,
            trainingTipId: tip.trainingTipId,
            languageId: tip.languageId,
            resourceId: tip.resourceId
        )
        
        return repository
            .storeCompletedTrainingTip(trainingTipDataModel)
            .flatMap { completedTrainingTipDataModel in
                
                let domainModel = TrainingTipDomainModel(
                    trainingTipId: completedTrainingTipDataModel.trainingTipId,
                    resourceId: completedTrainingTipDataModel.resourceId,
                    languageId: completedTrainingTipDataModel.languageId
                )
                
                return Just(domainModel)
            }
            .eraseToAnyPublisher()
    }
}
