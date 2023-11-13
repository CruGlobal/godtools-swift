//
//  DidViewToolScreenShareUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DidViewToolScreenShareUseCase {
    
    private let incrementNumberOfToolScreenShareViewsRepositoryInterface: IncrementNumberOfToolScreenShareViewsRepositoryInterface
    
    init(incrementNumberOfToolScreenShareViewsRepositoryInterface: IncrementNumberOfToolScreenShareViewsRepositoryInterface) {
        
        self.incrementNumberOfToolScreenShareViewsRepositoryInterface = incrementNumberOfToolScreenShareViewsRepositoryInterface
    }
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func viewedToolScreenSharePublisher(tool: ResourceModel) -> AnyPublisher<Void, Never> {
        
        return incrementNumberOfToolScreenShareViewsRepositoryInterface
            .incrementNumberOfViewsForTool(tool: tool, incrementBy: 1)
            .eraseToAnyPublisher()
    }
}
