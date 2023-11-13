//
//  IncrementNumberOfToolScreenShareViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class IncrementNumberOfToolScreenShareViewsRepository: IncrementNumberOfToolScreenShareViewsRepositoryInterface {
    
    private let toolScreenShareViewsRepository: ToolScreenShareViewsRepository
    
    init(toolScreenShareViewsRepository: ToolScreenShareViewsRepository) {
        
        self.toolScreenShareViewsRepository = toolScreenShareViewsRepository
    }
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func incrementNumberOfViewsForTool(tool: ResourceModel, incrementBy: Int) -> AnyPublisher<Void, Never> {
        
        return toolScreenShareViewsRepository
            .incrementToolScreenShareViewPublisher(id: tool.id, incrementNumberOfViewsBy: incrementBy)
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
