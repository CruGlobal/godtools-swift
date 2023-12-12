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
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never> {
        
        appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never> in
              
                return self.getLessonEvaluationInterfaceStringsRepositoryInterface.getStringsPublisher(translateInAppLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
