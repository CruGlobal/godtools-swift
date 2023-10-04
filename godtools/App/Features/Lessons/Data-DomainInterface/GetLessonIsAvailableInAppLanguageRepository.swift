//
//  GetLessonIsAvailableInAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonIsAvailableInAppLanguageRepository: GetLessonIsAvailableInAppLanguageRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
    }
    
    func getLessonIsAvailableInAppLanguagePublisher(lesson: LessonDomainModel, appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<Bool, Never> {
        
        guard let lessonDataModel = resourcesRepository.getResource(id: lesson.id),
              let appLanguageDataModel = languagesRepository.getLanguage(code: appLanguage) else {
            
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        let supportsAppLanguage: Bool = lessonDataModel.supportsLanguage(languageId: appLanguageDataModel.id)
        
        return Just(supportsAppLanguage)
            .eraseToAnyPublisher()
    }
}
