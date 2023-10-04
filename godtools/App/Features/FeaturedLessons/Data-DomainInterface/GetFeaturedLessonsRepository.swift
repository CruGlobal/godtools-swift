//
//  GetFeaturedLessonsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFeaturedLessonsRepository: GetFeaturedLessonsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
    }
    
    func getFeaturedLessonsPublisher() -> AnyPublisher<[LessonDomainModel], Never> {
        
        let lessons: [ResourceModel] = resourcesRepository.getAllLessons()
        
        let featuredLessonsDataModels: [ResourceModel] = lessons.filter({
            $0.attrSpotlight == true
        })
        
        let featuredLessons: [LessonDomainModel] = featuredLessonsDataModels.map { (resource: ResourceModel) in
            
            LessonDomainModel(
                analyticsToolName: resource.abbreviation,
                bannerImageId: resource.attrBanner,
                id: resource.id
            )
        }
        
        return Just(featuredLessons)
            .eraseToAnyPublisher()
    }
    
    func observeFeaturedLessonsChangedPublisher() -> AnyPublisher<Void, Never> {
        return resourcesRepository.getResourcesChangedPublisher()
            .eraseToAnyPublisher()
    }
}
