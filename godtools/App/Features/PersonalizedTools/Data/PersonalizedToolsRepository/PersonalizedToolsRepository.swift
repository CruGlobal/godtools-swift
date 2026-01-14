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
    
    init(api: PersonalizedToolsApi) {
        
        self.api = api
    }
    
    func getAllRankedResourcesPublisher(requestPriority: RequestPriority, country: String?, language: String?, resouceType: ResourceType?) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return api
            .getAllRankedResourcesPublisher(requestPriority: requestPriority, country: country, language: language, resouceType: resouceType)
            .map { (resourceCodables: [ResourceCodable]) in
                
                let dataModels: [ResourceDataModel] = resourceCodables.map {
                    ResourceDataModel(interface: $0)
                }
                
                return dataModels
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
