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
    
    private let api: PersonalizedToolsApiInterface
    private let cache: PersonalizedToolsCache
    private let resourcesRepository: ResourcesRepository
    private let sync: PersonalizedToolsSync
    
    init(
        api: PersonalizedToolsApiInterface,
        cache: PersonalizedToolsCache,
        resourcesRepository: ResourcesRepository,
        sync: PersonalizedToolsSync
    ) {

        self.api = api
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
        
        Task {
            try await sync.syncPersonalizedTools(
                requestPriority: requestPriority,
                country: country,
                language: language,
                forceNewSync: forceNewSync
            )
        }

        return cache
            .persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
}

// MARK: - Persistence

extension PersonalizedToolsRepository {

    func getPersistedPersonalizedTools(country: String?, language: String, resourceTypes: [ResourceType]?) async throws -> [ResourceDataModel] {

        let type = PersonalizedToolsType(country: country, language: language)

        switch type {

        case .allRanked(let country, let language):
            return try await getPersistedAllRankedTools(country: country, language: language, resourceTypes: resourceTypes)

        case .defaultOrder(let language):
            return try await getPersistedDefaultOrderTools(language: language, resourceTypes: resourceTypes)
        }
    }

    func getPersistedAllRankedTools(country: String, language: String, resourceTypes: [ResourceType]? = nil) async throws -> [ResourceDataModel] {

        let personalizedTools: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: try PersonalizedToolsId.createForAllRankedTools(country: country, language: language).value
        )

        return try await getPersistedResources(personalizedTools: personalizedTools, resourceTypes: resourceTypes)
    }

    func getPersistedDefaultOrderTools(language: String, resourceTypes: [ResourceType]? = nil) async throws -> [ResourceDataModel] {

        let personalizedTools: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: PersonalizedToolsId.createForDefaultOrder(language: language).value
        )

        return try await getPersistedResources(personalizedTools: personalizedTools, resourceTypes: resourceTypes)
    }

    private func getPersistedResources(personalizedTools: PersonalizedToolsDataModel?, resourceTypes: [ResourceType]?) async throws -> [ResourceDataModel] {

        guard let personalizedTools = personalizedTools else {
            return Array()
        }

        let resources = try await resourcesRepository.getResourcesByIds(ids: personalizedTools.resourceIds)

        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return resources
        }

        let resourceTypeRawValues = Set(resourceTypes.map { $0.rawValue })

        return resources.filter { resourceTypeRawValues.contains($0.resourceType) }
    }
}
