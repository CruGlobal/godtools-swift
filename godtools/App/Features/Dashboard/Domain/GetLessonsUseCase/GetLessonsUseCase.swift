//
//  GetLessonsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsUseCase {
    
    private let getLessonUseCase: GetLessonUseCase
    private let resourcesRepository: ResourcesRepository
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    init(getLessonUseCase: GetLessonUseCase, resourcesRepository: ResourcesRepository, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
       
        self.getLessonUseCase = getLessonUseCase
        self.resourcesRepository = resourcesRepository
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
    }
    
    func getLessonsPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
        .flatMap({ (resourcesChanged: Void, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[LessonDomainModel], Never> in
            
            let lessons: [LessonDomainModel] = self.getLessons(primaryLanguage: primaryLanguage)
            
            return Just(lessons)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getLessons(primaryLanguage: LanguageDomainModel?) -> [LessonDomainModel] {
        
        return resourcesRepository.getAllLessons().map { (resource: ResourceModel) in
            
            getLessonUseCase.getLesson(resource: resource, primaryLanguage: primaryLanguage)
        }
    }
}
