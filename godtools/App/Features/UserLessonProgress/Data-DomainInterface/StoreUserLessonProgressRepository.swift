//
//  StoreUserLessonProgressRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 9/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserLessonProgressRepository: StoreUserLessonProgressRepositoryInterface {
    
    private let lessonProgressRepository: UserLessonProgressRepository
    
    init(lessonProgressRepository: UserLessonProgressRepository) {
        self.lessonProgressRepository = lessonProgressRepository
    }
    
    func storeLessonProgress(lessonId: String, lastViewedPageId: String, lastViewedPageNumber: Int, totalPageCount: Int) -> AnyPublisher<UserLessonProgressDomainModel, Error> {
        
        let progress: Double
        if totalPageCount < 1 {
            progress = 0
        } else {
            progress = Double(lastViewedPageNumber) / Double(totalPageCount)
        }
        
        let lessonProgress = UserLessonProgressDataModel(
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: progress
        )
        
        return lessonProgressRepository.storeLessonProgress(lessonProgress)
            .map {
                UserLessonProgressDomainModel(dataModel: $0)
            }
            .eraseToAnyPublisher()
    }
}
