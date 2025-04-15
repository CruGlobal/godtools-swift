//
//  TrackViewedLessonSwipeTutorialUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackViewedLessonSwipeTutorialUseCase {
    
    private let trackViewedLessonSwipeTutorialRepo: TrackViewedLessonSwipeTutorialRepositoryInterface
    
    init(trackViewedLessonSwipeTutorialRepo: TrackViewedLessonSwipeTutorialRepositoryInterface) {
        self.trackViewedLessonSwipeTutorialRepo = trackViewedLessonSwipeTutorialRepo
    }
    
    func trackLessonSwipeTutorialViewed() -> AnyPublisher<Void, Never> {
        return trackViewedLessonSwipeTutorialRepo.trackSwipeTutorialViewedPublisher()
    }
}
