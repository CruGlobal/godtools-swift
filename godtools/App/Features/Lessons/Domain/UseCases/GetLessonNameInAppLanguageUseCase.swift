//
//  GetLessonNameInAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonNameInAppLanguageUseCase {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLessonNameRepositoryInterface: GetLessonNameRepositoryInterface
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonNameRepositoryInterface: GetLessonNameRepositoryInterface) {
        
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonNameRepositoryInterface = getLessonNameRepositoryInterface
    }
    
    func getLessonNamePublisher(lesson: LessonDomainModel) -> AnyPublisher<LessonNameDomainModel, Never> {
        
        return getCurrentAppLanguageUseCase.getLanguagePublisher()
            .flatMap({ (currentAppLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<LessonNameDomainModel, Never> in
                
                return self.getLessonNameRepositoryInterface.getLessonNameInAppLanguagePublisher(lesson: lesson, appLanguage: currentAppLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
