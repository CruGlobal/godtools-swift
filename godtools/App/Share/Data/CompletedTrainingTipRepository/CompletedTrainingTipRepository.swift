//
//  CompletedTrainingTipRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

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
    
    func storeCompletedTrainingTipPublisher(completedTrainingTip: CompletedTrainingTipDataModel) -> AnyPublisher<CompletedTrainingTipDataModel, Error> {
        
        return AnyPublisher() {
            
            _ = try await self.cache.persistence.writeObjectsAsync(
                externalObjects: [completedTrainingTip],
                writeOption: nil,
                getOption: nil
            )
            
            return completedTrainingTip
        }
    }
}
