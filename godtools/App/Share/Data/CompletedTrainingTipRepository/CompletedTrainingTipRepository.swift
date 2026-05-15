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
    
    func getCompletedTrainingTip(id: String) -> CompletedTrainingTipDataModel? {
        
        do {
            return try cache.persistence.getDataModel(id: id)
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
    
    func storeCompletedTrainingTip(id: String, resourceId: String, languageId: String) async throws {
        
        let trainingTipDataModel = CompletedTrainingTipDataModel(
            id: id,
            trainingTipId: id,
            languageId: resourceId,
            resourceId: languageId
        )
        
        _ = try await cache.persistence.writeObjectsAsync(
            externalObjects: [trainingTipDataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
