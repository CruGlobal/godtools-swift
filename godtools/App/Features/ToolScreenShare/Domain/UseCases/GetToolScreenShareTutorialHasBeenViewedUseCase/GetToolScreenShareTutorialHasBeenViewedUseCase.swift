//
//  GetToolScreenShareTutorialHasBeenViewedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCaseInterface {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func execute(toolId: String) -> Bool {
        
        let toolScreenShare: ToolScreenShareTutorialViewDataModel? = tutorialViewsRepository.getToolScreenShareTutorialView(id: toolId)
        
        let numberOfViews: Int = toolScreenShare?.numberOfViews ?? 0
        
        let hasBeenViewed: Bool = numberOfViews >= 3
        
        return hasBeenViewed
    }
}
