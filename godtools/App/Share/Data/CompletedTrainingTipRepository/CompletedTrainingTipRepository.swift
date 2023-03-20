//
//  CompletedTrainingTipRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 2/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class CompletedTrainingTipRepository {
    
    private let cache: RealmCompletedTrainingTipCache
    
    init(cache: RealmCompletedTrainingTipCache) {
        
        self.cache = cache
    }
    
    func getCompletedTrainingTip(id: String) -> CompletedTrainingTipDataModel? {
        
        return cache.getCompletedTrainingTip(id: id)
    }
    
    func getNumberOfCompletedTrainingTips() -> Int {
        
        return cache.countCompletedTrainingTips()
    }
    
    func storeCompletedTrainingTip(_ completedTrainingTip: CompletedTrainingTipDataModel) -> AnyPublisher<CompletedTrainingTipDataModel, Error> {
        
        return cache.storeCompletedTrainingTip(completedTrainingTip: completedTrainingTip)
    }
}
