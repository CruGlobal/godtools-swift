//
//  DidViewToolScreenShareTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class DidViewToolScreenShareTutorialUseCase {
    
    private let tutorialViewsRepository: ToolScreenShareTutorialViewsRepository
    
    init(tutorialViewsRepository: ToolScreenShareTutorialViewsRepository) {
        
        self.tutorialViewsRepository = tutorialViewsRepository
    }
    
    func execute(toolId: String) -> AnyPublisher<Void, Never> {
        
        return tutorialViewsRepository
            .incrementNumberOfViewsPublisher(
                id: toolId,
                incrementNumberOfViewsBy: 1
            )
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
