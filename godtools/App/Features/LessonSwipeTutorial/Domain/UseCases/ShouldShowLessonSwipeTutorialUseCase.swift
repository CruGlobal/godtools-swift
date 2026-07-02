//
//  ShouldShowLessonSwipeTutorialUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ShouldShowLessonSwipeTutorialUseCase {

    private let lessonSwipeTutorialViewedRepo: LessonSwipeTutorialViewedRepository
    
    init(lessonSwipeTutorialViewedRepo: LessonSwipeTutorialViewedRepository) {
        self.lessonSwipeTutorialViewedRepo = lessonSwipeTutorialViewedRepo
    }
    
    func execute() -> Bool {
        
        let swipeTutorialViewed = lessonSwipeTutorialViewedRepo.getLessonSwipeTutorialViewed()
        
        return !swipeTutorialViewed
    }
}
