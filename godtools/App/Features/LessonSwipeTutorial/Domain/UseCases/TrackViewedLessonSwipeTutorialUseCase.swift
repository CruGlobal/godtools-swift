//
//  TrackViewedLessonSwipeTutorialUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class TrackViewedLessonSwipeTutorialUseCase {
    
    private let lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository
    
    init(lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository) {
        self.lessonSwipeTutorialViewedRepository = lessonSwipeTutorialViewedRepository
    }
    
    func execute() -> AnyPublisher<Void, Never> {
        
        lessonSwipeTutorialViewedRepository.storeLessonSwipeTutorialViewed(viewed: true)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
