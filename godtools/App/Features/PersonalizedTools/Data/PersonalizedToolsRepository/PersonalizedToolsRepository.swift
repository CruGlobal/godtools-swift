//
//  PersonalizedToolsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

final class PersonalizedToolsRepository: Sendable {
    
    private let cache: PersonalizedToolsCache
    private let resourcesRepository: ResourcesRepository
    private let sync: PersonalizedToolsSync
    
    init(
        cache: PersonalizedToolsCache,
        resourcesRepository: ResourcesRepository,
        sync: PersonalizedToolsSync
    ) {

        self.cache = cache
        self.resourcesRepository = resourcesRepository
        self.sync = sync
    }

    @MainActor func getPersonalizedToolsChanged(
        requestPriority: RequestPriority,
        country: String?,
        language: String,
        forceNewSync: Bool = false
    ) -> AnyPublisher<Void, Error> {
        
        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
}

// MARK: - Persistence

extension PersonalizedToolsRepository {
    
    func getTools(
        requestPriority: RequestPriority,
        type: PersonalizedToolsType,
        resourceTypes: [ResourceType]?,
        sortByResponse: Bool
    ) async throws -> [ResourceDataModel] {

        let id: String = try PersonalizedToolsId(type: type).value
        
        let personalizedTools: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: id
        )
        
        try await sync.syncType(
            requestPriority: requestPriority,
            type: type,
            forceNewSync: false
        )

        return try await getPersistedResources(
            personalizedTools: personalizedTools,
            resourceTypes: resourceTypes,
            sortByResponse: sortByResponse
        )
    }

    private func getPersistedResources(
        personalizedTools: PersonalizedToolsDataModel?,
        resourceTypes: [ResourceType]?,
        sortByResponse: Bool
    ) async throws -> [ResourceDataModel] {

        guard let personalizedTools = personalizedTools else {
            return Array()
        }

        let resources: [ResourceDataModel]
        
        if sortByResponse {
            
            // NOTE: If the size of the list of tools were to grow, this could be a high overhead cost since the list is iterated one at a time fetching a resource per iteration.
            // It would be better optimized to create a new object type using a sort descriptor.  However, this list will most likely remain fairly small. ~Levi
            
            if personalizedTools.resourceIds.count > 50 {
                assertionFailure("Potential overhead fetching 1 item at a time.")
            }
            
            var sortedResources: [ResourceDataModel] = Array()
            
            for resourceId in personalizedTools.resourceIds {
                
                guard let resource = resourcesRepository.getResourceById(id: resourceId) else {
                    continue
                }
                
                sortedResources.append(resource)
            }
            
            resources = sortedResources
        }
        else {
            resources = try await resourcesRepository.getResourcesByIds(ids: personalizedTools.resourceIds)
        }

        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return resources
        }

        let resourceTypeRawValues = Set(resourceTypes.map { $0.rawValue })

        return resources.filter { resourceTypeRawValues.contains($0.resourceType) }
    }
}
