//
//  CompletedTrainingTipRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class CompletedTrainingTipRepository {
    
    private let cache: CompletedTrainingTipCache
    
    init(cache: CompletedTrainingTipCache) {
        
        self.cache = cache
    }
    
    func getCompletedTrainingTip(id: TrainingTipId) -> CompletedTrainingTipDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: id.value)
        }
        catch _ {
            return nil
        }
    }
    
    func getNumberOfCompletedTrainingTips() -> Int {
        
        do {
            return try cache.persistence.getObjectCount()
        }
        catch _ {
            return 0
        }
    }
    
    func storeCompletedTrainingTip(id: TrainingTipId) async throws {
        
        let trainingTipDataModel = CompletedTrainingTipDataModel(
            id: id
        )
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [trainingTipDataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
