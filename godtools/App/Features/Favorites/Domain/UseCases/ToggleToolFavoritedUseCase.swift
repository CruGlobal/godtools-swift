//
//  ToggleToolFavoritedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ToggleToolFavoritedUseCase {
            
    private let toggleToolFavoritedRepository: ToggleToolFavoritedRepositoryInterface
    
    init(toggleToolFavoritedRepository: ToggleToolFavoritedRepositoryInterface) {
        
        self.toggleToolFavoritedRepository = toggleToolFavoritedRepository
    }
    
    func toggleFavoritedPublisher(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Never> {
                        
        return toggleToolFavoritedRepository
            .toggleFavoritedPublisher(toolId: toolId)
            .eraseToAnyPublisher()
    }
}
