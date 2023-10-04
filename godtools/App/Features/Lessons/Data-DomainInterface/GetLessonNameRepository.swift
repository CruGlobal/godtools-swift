//
//  GetLessonNameRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/3/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonNameRepository: GetLessonNameRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let translationsRepository: TranslationsRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, translationsRepository: TranslationsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getLessonNameInAppLanguagePublisher(lesson: LessonDomainModel, appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<LessonNameDomainModel, Never> {
        
        let lessonId: String = lesson.id
        let lessonName: String
        
        if let appLanguageDataModel = languagesRepository.getLanguage(code: appLanguage), let translation = translationsRepository.getLatestTranslation(resourceId: lessonId, languageId: appLanguageDataModel.id) {
            
            lessonName = translation.translatedName
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: lessonId, languageCode: LanguageCodeDomainModel.english.value) {
            
            lessonName = englishTranslation.translatedName
        }
        else if let resourceDataModel = resourcesRepository.getResource(id: lessonId) {
            
            lessonName = resourceDataModel.resourceDescription
        }
        else {
            
            lessonName = ""
        }

        return Just(LessonNameDomainModel(value: lessonName))
            .eraseToAnyPublisher()
    }
}
