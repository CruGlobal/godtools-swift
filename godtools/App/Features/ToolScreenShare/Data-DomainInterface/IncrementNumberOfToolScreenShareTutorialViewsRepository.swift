//
//  IncrementNumberOfToolScreenShareTutorialViewsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class IncrementNumberOfToolScreenShareTutorialViewsRepository: IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func incrementNumberOfViewsForTool(toolId: String, incrementBy: Int) -> AnyPublisher<Void, Never> {
        
        return tutorialViewsRepository
            .incrementNumberOfViewsPublisher(id: toolId, incrementNumberOfViewsBy: incrementBy)
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
