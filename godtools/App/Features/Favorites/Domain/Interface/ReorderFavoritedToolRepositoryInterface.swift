//
//  ReorderFavoritedToolRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 3/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol ReorderFavoritedToolRepositoryInterface {
    
    func reorderFavoritedToolPubilsher(toolId: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[ReorderFavoritedToolDomainModel], Error>
}
