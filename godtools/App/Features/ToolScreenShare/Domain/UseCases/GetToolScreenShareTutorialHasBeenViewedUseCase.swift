//
//  GetToolScreenShareTutorialHasBeenViewedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolScreenShareTutorialHasBeenViewedUseCase {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func execute(toolId: String) -> AnyPublisher<ToolScreenShareTutorialViewedDomainModel, Never> {
        
        return tutorialViewsRepository
            .getToolScreenShareTutorialViewPublisher(id: toolId)
            .map { (toolScreenShare: ToolScreenShareTutorialViewDataModel?) in
                
                let numberOfViews: Int = toolScreenShare?.numberOfViews ?? 0
                
                return ToolScreenShareTutorialViewedDomainModel(numberOfViews: numberOfViews)
            }
            .eraseToAnyPublisher()
    }
}
