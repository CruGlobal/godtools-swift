//
//  GetLessonEvaluatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonEvaluatedUseCase {
    
    private let getLessonEvaluatedRepositoryInterface:  GetLessonEvaluatedRepositoryInterface
    
    init(getLessonEvaluatedRepositoryInterface:  GetLessonEvaluatedRepositoryInterface) {
        
        self.getLessonEvaluatedRepositoryInterface = getLessonEvaluatedRepositoryInterface
    }
    
    func getEvaluatedPublisher(lesson: ToolDomainModel) -> AnyPublisher<Bool, Never> {
        
        return getLessonEvaluatedRepositoryInterface.getLessonEvaluatedPublisher(lesson: lesson)
            .eraseToAnyPublisher()
    }
}
