//
//  StoreUserLessonProgressUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class StoreUserLessonProgressUseCase {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(lessonProgressRepository: UserLessonProgressRepository) {
        self.lessonProgressRepository = lessonProgressRepository
    }
    
    func execute(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<UserLessonProgressDomainModel, Error> {
        
        let progress: Double
        if totalPageCount < 1 {
            progress = 0
        } else {
            progress = Double(lastViewedPageNumber) / Double(totalPageCount)
        }
        
        return lessonProgressRepository
            .storeLessonProgressPublisher(
                lessonId: lessonId,
                lastViewedPageId: lastViewedPageId,
                progress: progress
            )
            .map {
                UserLessonProgressDomainModel(
                    lessonId: $0.lessonId,
                    lastViewedPageId: $0.lastViewedPageId,
                    progress: $0.progress
                )
            }
            .eraseToAnyPublisher()
    }
}
