//
//  DidViewToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class DidViewToolScreenShareTutorialUseCase: Sendable {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func execute(toolId: String) async throws {
        
        try await tutorialViewsRepository
            .incrementNumberOfViews(
                id: toolId,
                incrementNumberOfViewsBy: 1
            )
    }
}
