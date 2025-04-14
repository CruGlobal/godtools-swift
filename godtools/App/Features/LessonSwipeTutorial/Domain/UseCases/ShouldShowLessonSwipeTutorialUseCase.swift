//
//  ShouldShowLessonSwipeTutorialUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ShouldShowLessonSwipeTutorialUseCase {
    
    private let shouldShowLessonSwipeTutorialRepo: ShouldShowLessonSwipeTutorialRepositoryInterface
    
    init(shouldShowLessonSwipeTutorialRepo: ShouldShowLessonSwipeTutorialRepositoryInterface) {
        self.shouldShowLessonSwipeTutorialRepo = shouldShowLessonSwipeTutorialRepo
    }
    
    func shouldShowLessonSwipeTutorialPublisher() -> AnyPublisher<Bool, Never> {
        return shouldShowLessonSwipeTutorialRepo
            .shouldShowLessonSwipeTutorial()
    }
}
