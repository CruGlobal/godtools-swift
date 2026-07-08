//
//  TrackViewedLessonSwipeTutorialUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class TrackViewedLessonSwipeTutorialUseCase {
    
    private let lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository
    
    init(lessonSwipeTutorialViewedRepository: LessonSwipeTutorialViewedRepository) {
        self.lessonSwipeTutorialViewedRepository = lessonSwipeTutorialViewedRepository
    }
    
    func execute() async {
        
        lessonSwipeTutorialViewedRepository.storeLessonSwipeTutorialViewed(viewed: true)
    }
}
