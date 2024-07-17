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
    
    func getViewedPublisher(toolId: String) -> AnyPublisher<ToolScreenShareTutorialViewedDomainModel, Never> {
        
        return tutorialViewedRepositoryInterface.getViewed(toolId: toolId)
            .eraseToAnyPublisher()
    }
}
