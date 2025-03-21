//
//  ReorderFavoritedToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ReorderFavoritedToolUseCase {
    
    private let reorderFavoritedToolRepository: ReorderFavoritedToolRepositoryInterface
    
    init(reorderFavoritedToolRepository: ReorderFavoritedToolRepositoryInterface) {
        self.reorderFavoritedToolRepository = reorderFavoritedToolRepository
    }
    
    func reorderFavoritedToolPublisher(toolId: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return reorderFavoritedToolRepository.reorderFavoritedToolPubilsher(toolId: toolId, originalPosition: originalPosition, newPosition: newPosition)
    }
}
