//
//  GetToolScreenShareTutorialHasBeenViewedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolScreenShareTutorialHasBeenViewedUseCase {
    
    private let tutorialViewedRepositoryInterface: GetToolScreenShareTutorialViewedRepositoryInterface
    
    init(tutorialViewedRepositoryInterface: GetToolScreenShareTutorialViewedRepositoryInterface) {
        
        self.tutorialViewedRepositoryInterface = tutorialViewedRepositoryInterface
    }
    
    // TODO: Eventually ToolDomainModel should be passed in here instead of ResourceModel. ~Levi
    func getViewedPublisher(tool: ResourceModel) -> AnyPublisher<ToolScreenShareTutorialViewedDomainModel, Never> {
        
        return tutorialViewedRepositoryInterface.getViewed(tool: tool)
            .eraseToAnyPublisher()
    }
}
