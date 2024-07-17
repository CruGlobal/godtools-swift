//
//  GetLessonEvaluationInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonEvaluationInterfaceStringsUseCase {
    
    private let getLessonEvaluationInterfaceStringsRepositoryInterface: GetLessonEvaluationInterfaceStringsRepositoryInterface
    
    init(getLessonEvaluationInterfaceStringsRepositoryInterface: GetLessonEvaluationInterfaceStringsRepositoryInterface) {
        
        self.getLessonEvaluationInterfaceStringsRepositoryInterface = getLessonEvaluationInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never> {
        
        return getLessonEvaluationInterfaceStringsRepositoryInterface.getStringsPublisher(translateInAppLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
