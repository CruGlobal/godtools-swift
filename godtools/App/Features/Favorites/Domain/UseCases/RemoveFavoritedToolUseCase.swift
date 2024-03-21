//
//  RemoveFavoritedToolUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoveFavoritedToolUseCase {
    
    private let removeFavoritedToolRepository: RemoveFavoritedToolRepositoryInterface
    
    init(removeFavoritedToolRepository: RemoveFavoritedToolRepositoryInterface) {
        
        self.removeFavoritedToolRepository = removeFavoritedToolRepository
    }
    
    func removeToolPublisher(toolId: String) -> AnyPublisher<Void, Never> {
        
        return removeFavoritedToolRepository
            .removeToolPublisher(toolId: toolId)
            .eraseToAnyPublisher()
    }
}
