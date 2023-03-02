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
    private let deprecatedTipService: ViewedTrainingTipsService
    private let setCompletedTrainingTipUseCase: SetCompletedTrainingTipUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CompletedTrainingTipRepository, service: ViewedTrainingTipsService, setCompletedTrainingTipUseCase: SetCompletedTrainingTipUseCase) {
        
        self.repository = repository
        self.deprecatedTipService = service
        self.setCompletedTrainingTipUseCase = setCompletedTrainingTipUseCase
    }
    
    func hasTrainingTipBeenCompleted(tip: TrainingTipDomainModel) -> Bool {
        
        if repository.getCompletedTrainingTip(id: tip.id) != nil {
            
            return true
            
        } else if deprecatedTipService.containsViewedTrainingTip(id: tip.id) {
            
            // migrate old viewed training tips from userDefaults to Realm
            // TODO: - eventually remove this whole `else` once we're done migrating
            setCompletedTrainingTipUseCase.setTrainingTipAsCompleted(tip: tip)
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
            
            return true
            
        } else {
            
            return false
        }
    }
}
