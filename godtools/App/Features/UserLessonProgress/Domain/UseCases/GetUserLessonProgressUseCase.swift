//
//  GetUserLessonProgressUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserLessonProgressUseCase {
    
    private let getLessonProgressRepository: GetUserLessonProgressRepositoryInterface
    
    init(getLessonProgressRepository: GetUserLessonProgressRepositoryInterface) {
        self.getLessonProgressRepository = getLessonProgressRepository
    }
    
    func getLessonProgressPublisher(lessonId: String) -> AnyPublisher<UserLessonProgressDomainModel?, Never> {
        
        return getLessonProgressRepository.getLessonProgressPublisher(lessonId: lessonId)
    }
}
