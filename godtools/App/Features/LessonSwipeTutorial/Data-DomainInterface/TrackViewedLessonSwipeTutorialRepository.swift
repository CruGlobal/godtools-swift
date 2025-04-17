//
//  TrackViewedLessonSwipeTutorialRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackViewedLessonSwipeTutorialRepository: TrackViewedLessonSwipeTutorialRepositoryInterface {
    
    private let lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository
    
    init(lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository) {
        self.lessonSwipeTutorialViewedRepository = lessonSwipeTutorialViewedRepository
    }
    
    func trackSwipeTutorialViewedPublisher() -> AnyPublisher<Void, Never> {
        
        lessonSwipeTutorialViewedRepository.storeLessonSwipeTutorialViewed(viewed: true)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
