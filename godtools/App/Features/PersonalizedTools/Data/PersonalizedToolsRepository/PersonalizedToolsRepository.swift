//
//  PersonalizedToolsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

final class PersonalizedToolsRepository {
    
    private let api: PersonalizedToolsApi
    private let cache: PersonalizedToolsCache
    
    init(api: PersonalizedToolsApi, cache: PersonalizedToolsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func getAllRankedResourcesPublisher(requestPriority: RequestPriority, country: String, language: String, resourceType: ResourceType?) -> AnyPublisher<[PersonalizedToolsDataModel], Error> {

        return api
            .getAllRankedResourcesPublisher(requestPriority: requestPriority, country: country, language: language, resourceType: resourceType)
            .flatMap { (resourceCodables: [ResourceCodable]) in

                let resources: [ResourceDataModel] = resourceCodables.map {
                    ResourceDataModel(interface: $0)
                }

                let lessons = resources.filter { $0.resourceTypeEnum.isLessonType }
                let tools = resources.filter { $0.resourceTypeEnum.isToolType }

                let personalizedLessons = PersonalizedToolsDataModel(
                    country: country,
                    language: language,
                    resourceIds: lessons.map { $0.id }
                )

                let personalizedTools = PersonalizedToolsDataModel(
                    country: country,
                    language: language,
                    resourceIds: tools.map { $0.id }
                )

                return self.cache.syncPersonalizedTools([personalizedLessons, personalizedTools])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getDefaultOrderResourcesPublisher(requestPriority: RequestPriority, language: String?, resouceType: ResourceType?) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return api
            .getDefaultOrderResourcesPublisher(requestPriority: requestPriority, language: language, resouceType: resouceType)
            .map { (resourceCodables: [ResourceCodable]) in
                
                let dataModels: [ResourceDataModel] = resourceCodables.map {
                    ResourceDataModel(interface: $0)
                }
                
                return dataModels
            }
            .eraseToAnyPublisher()
    }
}
