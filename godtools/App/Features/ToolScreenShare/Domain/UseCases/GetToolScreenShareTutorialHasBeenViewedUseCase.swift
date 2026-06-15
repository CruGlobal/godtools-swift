//
//  GetToolScreenShareTutorialHasBeenViewedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialHasBeenViewedUseCase {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func execute(toolId: String) -> ToolScreenShareTutorialViewedDomainModel {
        
        let toolScreenShare: ToolScreenShareTutorialViewDataModel? = tutorialViewsRepository.getToolScreenShareTutorialView(id: toolId)
        
        let numberOfViews: Int = toolScreenShare?.numberOfViews ?? 0
        
        return ToolScreenShareTutorialViewedDomainModel(numberOfViews: numberOfViews)
    }
}
