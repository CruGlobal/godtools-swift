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
    
    func didViewPublisher(toolId: String) -> AnyPublisher<Void, Never> {
        
        return incrementNumberOfViewsRepositoryInterface
            .incrementNumberOfViewsForTool(toolId: toolId, incrementBy: 1)
            .eraseToAnyPublisher()
    }
}
