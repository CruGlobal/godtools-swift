//
//  GetLessonsListRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLessonsListRepository: GetLessonsListRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
    }
    
    func getLessonsListPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        let lessons: [ResourceModel] = resourcesRepository.getAllLessons()
        
        let lessonListItems: [LessonDomainModel] = lessons.map { (resource: ResourceModel) in
            
            LessonDomainModel(
                analyticsToolName: resource.abbreviation,
                bannerImageId: resource.attrBanner,
                id: resource.id
            )
        }
        
        return Just(lessonListItems)
            .eraseToAnyPublisher()
    }
    
    func observeLessonsChangedPublisher() -> AnyPublisher<Void, Never> {
        return resourcesRepository.getResourcesChangedPublisher()
            .eraseToAnyPublisher()
    }
}
