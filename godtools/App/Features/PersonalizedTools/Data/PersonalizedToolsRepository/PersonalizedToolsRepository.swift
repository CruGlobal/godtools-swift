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

final class PersonalizedToolsRepository: RepositorySync<PersonalizedToolsDataModel, NoExternalDataFetch<PersonalizedToolsDataModel>> {

    private let api: PersonalizedToolsApi
    private let cache: PersonalizedToolsCache
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    private let resourcesRepository: ResourcesRepository

    private var cancellables: Set<AnyCancellable> = Set()

    init(persistence: any Persistence<PersonalizedToolsDataModel, PersonalizedToolsDataModel>, api: PersonalizedToolsApi, cache: PersonalizedToolsCache, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface, resourcesRepository: ResourcesRepository) {

        self.api = api
        self.cache = cache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        self.resourcesRepository = resourcesRepository

        super.init(
            externalDataFetch: NoExternalDataFetch<PersonalizedToolsDataModel>(),
            persistence: persistence
        )
    }

    private func getSyncInvalidator(id: PersonalizedToolsId) -> SyncInvalidator {

        let id: String = "\(String(describing: PersonalizedToolsRepository.self)).syncPersonalizedTools.\(id.value)"

        return SyncInvalidator(
            id: id,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
    }

    @MainActor func getPersonalizedToolsChanged(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) -> AnyPublisher<Void, Error> {

        syncPersonalizedToolsPublisher(
            requestPriority: requestPriority,
            country: country,
            language: language,
            forceNewSync: forceNewSync
        )
        .sink { completion in

        } receiveValue: { _ in

        }
        .store(in: &cancellables)

        return persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
}

// MARK: - Persistence

extension PersonalizedToolsRepository {

    func getPersistedPersonalizedToolsPublisher(country: String?, language: String, resourceTypes: [ResourceType]?) -> AnyPublisher<[ResourceDataModel], Error> {

        return AnyPublisher() {
            return try await self.getPersistedPersonalizedTools(country: country, language: language, resourceTypes: resourceTypes)
        }
    }

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

        let personalizedTools: PersonalizedToolsDataModel? = try persistence.getDataModel(
            id: try PersonalizedToolsId.createForAllRankedTools(country: country, language: language).value
        )

        return try await getPersistedResources(personalizedTools: personalizedTools, resourceTypes: resourceTypes)
    }

    func getPersistedDefaultOrderTools(language: String, resourceTypes: [ResourceType]? = nil) async throws -> [ResourceDataModel] {

        let personalizedTools: PersonalizedToolsDataModel? = try persistence.getDataModel(
            id: PersonalizedToolsId.createForDefaultOrder(language: language).value
        )

        return try await getPersistedResources(personalizedTools: personalizedTools, resourceTypes: resourceTypes)
    }

    private func getPersistedResources(personalizedTools: PersonalizedToolsDataModel?, resourceTypes: [ResourceType]?) async throws -> [ResourceDataModel] {

        guard let personalizedTools = personalizedTools else {
            return Array()
        }

        let resources = try await resourcesRepository.persistence.getDataModelsAsync(getOption: .objectsByIds(ids: personalizedTools.resourceIds))

        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else {
            return resources
        }

        let resourceTypeRawValues = Set(resourceTypes.map { $0.rawValue })

        return resources.filter { resourceTypeRawValues.contains($0.resourceType) }
    }
}

// MARK: - Sync

extension PersonalizedToolsRepository {

    func syncPersonalizedToolsPublisher(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {

        return AnyPublisher() {

            return try await self.syncPersonalizedTools(
                requestPriority: requestPriority,
                country: country,
                language: language,
                forceNewSync: forceNewSync
            )
        }
    }

    private func syncPersonalizedTools(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) async throws -> [ResourceDataModel] {

        let type = PersonalizedToolsType(country: country, language: language)

        let personalizedToolId = try PersonalizedToolsId(type: type)

        let syncInvalidator: SyncInvalidator = getSyncInvalidator(
            id: personalizedToolId
        )

        let shouldSync: Bool = syncInvalidator.shouldSync || forceNewSync

        guard shouldSync else {

            switch type {

            case .allRanked(let country, let language):
                return try await getPersistedAllRankedTools(country: country, language: language)

            case .defaultOrder(let language):
                return try await getPersistedDefaultOrderTools(language: language)
            }
        }

        let resourceCodables: [ResourceCodable]

        switch type {

        case .allRanked(let country, let language):
            resourceCodables = try await api.getAllRankedResources(
                requestPriority: requestPriority,
                country: country,
                language: language,
                resourceTypes: nil
            )

        case .defaultOrder(let language):
            resourceCodables = try await api.getDefaultOrderResources(
                requestPriority: requestPriority,
                language: language,
                resourceTypes: nil
            )
        }

        let personalizedTools = try PersonalizedToolsDataModel.createFromCountry(
            country: country,
            language: language,
            resourceIds: resourceCodables.map { $0.id }
        )

        _ = try await persistence.writeObjectsAsync(
            externalObjects: [personalizedTools],
            writeOption: nil,
            getOption: nil
        )

        syncInvalidator.didSync()

        return try await getPersistedResources(personalizedTools: personalizedTools, resourceTypes: nil)
    }
}
