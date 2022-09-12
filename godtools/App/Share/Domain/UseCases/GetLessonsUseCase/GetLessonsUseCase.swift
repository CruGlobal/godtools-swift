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
    
    init(getLessonUseCase: GetLessonUseCase, resourcesRepository: ResourcesRepository) {
        self.getLessonUseCase = getLessonUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getLessonsPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[LessonDomainModel], Never> in
                
                let lessons = self.getLessons()
                
                return Just(lessons)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getLessons() -> [LessonDomainModel] {
        
        return resourcesRepository.getAllLessons()
            .map { getLessonUseCase.getLesson(resource: $0) }
    }
    
}
