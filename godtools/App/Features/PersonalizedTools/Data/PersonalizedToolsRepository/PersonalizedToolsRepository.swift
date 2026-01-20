//
//  PersonalizedToolsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PersonalizedToolsRepository {
    
    private let api: PersonalizedToolsApi
    
    init(api: PersonalizedToolsApi) {
        
        self.api = api
    }
    
    func getAllRankedResources(requestPriority: RequestPriority, country: String?, language: String?, resouceType: ResourceType?) async throws -> [ResourceDataModel] {
        
        let resources: [ResourceCodable] = try await api.getAllRankedResources(
            requestPriority: requestPriority,
            country: country,
            language: language,
            resouceType: resouceType
        )
        
        return resources.map {
            ResourceDataModel(interface: $0)
        }
    }
    
    func getDefaultOrderResources(requestPriority: RequestPriority, language: String?, resouceType: ResourceType?) async throws -> [ResourceDataModel] {
        
        let resources: [ResourceCodable] = try await api.getDefaultOrderResources(
            requestPriority: requestPriority,
            language: language,
            resouceType: resouceType
        )
        
        return resources.map {
            ResourceDataModel(interface: $0)
        }
    }
}
