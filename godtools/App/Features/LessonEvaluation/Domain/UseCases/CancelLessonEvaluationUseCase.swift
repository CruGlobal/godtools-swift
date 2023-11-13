//
//  CancelLessonEvaluationUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class CancelLessonEvaluationUseCase {
    
    private let cancelLessonEvaluationRepositoryInterface: CancelLessonEvaluationRepositoryInterface
    
    init(cancelLessonEvaluationRepositoryInterface: CancelLessonEvaluationRepositoryInterface) {
        
        self.cancelLessonEvaluationRepositoryInterface = cancelLessonEvaluationRepositoryInterface
    }
    
    func cancelPublisher(lesson: ToolDomainModel) -> AnyPublisher<Void, Never> {
        
        return cancelLessonEvaluationRepositoryInterface.cancelPublisher(lesson: lesson)
            .eraseToAnyPublisher()
    }
}
