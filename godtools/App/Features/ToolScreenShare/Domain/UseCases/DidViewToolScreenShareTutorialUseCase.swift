//
//  DidViewToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DidViewToolScreenShareTutorialUseCase {
    
    private let incrementNumberOfViewsRepositoryInterface: IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface
    
    init(incrementNumberOfViewsRepositoryInterface: IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface) {
        
        self.incrementNumberOfViewsRepositoryInterface = incrementNumberOfViewsRepositoryInterface
    }
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func didViewPublisher(tool: ResourceModel) -> AnyPublisher<Void, Never> {
        
        return incrementNumberOfViewsRepositoryInterface
            .incrementNumberOfViewsForTool(tool: tool, incrementBy: 1)
            .eraseToAnyPublisher()
    }
}
