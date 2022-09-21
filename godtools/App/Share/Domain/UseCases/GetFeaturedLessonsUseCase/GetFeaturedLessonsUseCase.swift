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
    
    init(getLessonUseCase: GetLessonUseCase, resourcesRepository: ResourcesRepository) {
        self.getLessonUseCase = getLessonUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getFeaturedLessonsPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[LessonDomainModel], Never> in
                
                let featuredLessons = self.getFeaturedLessons()
                
                return Just(featuredLessons)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getFeaturedLessons() -> [LessonDomainModel] {
        
        return resourcesRepository.getFeaturedLessons()
            .map { getLessonUseCase.getLesson(resource: $0) }
    }
}
