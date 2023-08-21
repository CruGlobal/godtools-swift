//
//  GetFeaturedLessonsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/19/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFeaturedLessonsUseCase {
    
    private let getLessonUseCase: GetLessonUseCase
    private let resourcesRepository: ResourcesRepository
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    
    init(getLessonUseCase: GetLessonUseCase, resourcesRepository: ResourcesRepository, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase) {
        
        self.getLessonUseCase = getLessonUseCase
        self.resourcesRepository = resourcesRepository
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
    }
    
    func getFeaturedLessonsPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
        .flatMap({ (resourcesChanged: Void, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[LessonDomainModel], Never> in
                
            let featuredLessons: [LessonDomainModel] = self.getFeaturedLessons(primaryLanguage: primaryLanguage)
                
            return Just(featuredLessons)
                    .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func getFeaturedLessons(primaryLanguage: LanguageDomainModel?) -> [LessonDomainModel] {
                
        return resourcesRepository.getFeaturedLessons().map { (resource: ResourceModel) in
            
            getLessonUseCase.getLesson(resource: resource, primaryLanguage: primaryLanguage)
        }
    }
}
