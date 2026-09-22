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
        
        try await sync.syncType(
            requestPriority: requestPriority,
            type: type,
            forceNewSync: false
        )

        let personalizedTools: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: id
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

        guard let personalizedTools = personalizedTools, !personalizedTools.resourceIds.isEmpty else {
            return Array()
        }

        let unsortedResources: [ResourceDataModel] = try await resourcesRepository
            .getResourcesByIds(ids: personalizedTools.resourceIds)

        let resources: [ResourceDataModel]

        if sortByResponse {

            let resourcesById: [String: ResourceDataModel] = Dictionary(
                unsortedResources.map { ($0.id, $0) },
                uniquingKeysWith: { (firstResource: ResourceDataModel, _: ResourceDataModel) in firstResource }
            )

            resources = personalizedTools.resourceIds.compactMap { resourcesById[$0] }
        }
        else {
            resources = unsortedResources
        }

        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return resources
        }

        let resourceTypeRawValues: Set<String> = Set(resourceTypes.map { $0.rawValue })

        return resources.filter { resourceTypeRawValues.contains($0.resourceType) }
    }
}
