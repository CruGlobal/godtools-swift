//
//  PersonalizedLessonsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

final class PersonalizedLessonsRepository: RepositorySync<PersonalizedLessonsDataModel, NoExternalDataFetch<PersonalizedLessonsDataModel>> {

    private let api: PersonalizedToolsApi
    private let cache: PersonalizedLessonsCache
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    private let resourcesRepository: ResourcesRepository

    private var cancellables: Set<AnyCancellable> = Set()

    init(persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>, api: PersonalizedToolsApi, cache: PersonalizedLessonsCache, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface, resourcesRepository: ResourcesRepository) {

        self.api = api
        self.cache = cache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        self.resourcesRepository = resourcesRepository
        
        super.init(
            externalDataFetch: NoExternalDataFetch<PersonalizedLessonsDataModel>(),
            persistence: persistence
        )
    }
    
    private func getSyncInvalidator(id: PersonalizedLessonsId) -> SyncInvalidator {
        
        let id: String = "\(String(describing: PersonalizedLessonsRepository.self)).syncPersonalizedLessons.\(id.value)"
        
        return SyncInvalidator(
            id: id,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
    }

    @MainActor func getPersonalizedLessonsChanged(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) -> AnyPublisher<Void, Error> {

        syncPersonalizedLessonsPublisher(
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

extension PersonalizedLessonsRepository {
    
    func getPersistedPersonalizedLessonsPublisher(country: String?, language: String) -> AnyPublisher<[ResourceDataModel], Error> {
        
        return AnyPublisher() {
            return try await self.getPersistedPersonalizedLessons(country: country, language: language)
        }
    }

    func getPersistedPersonalizedLessons(country: String?, language: String) async throws -> [ResourceDataModel] {

        let type = PersonalizedLessonsType(country: country, langauge: language)
        
        switch type {
            
        case .allRanked(let country, let language):
            return try await getPersistedAllRankedLessons(country: country, language: language)
            
        case .defaultOrder(let language):
            return try await getPersistedDefaultOrderLessons(language: language)
        }
    }
    
    func getPersistedAllRankedLessons(country: String, language: String) async throws -> [ResourceDataModel] {
        
        let personalizedLessons: PersonalizedLessonsDataModel? = try persistence.getDataModel(
            id: try PersonalizedLessonsId.createForAllRankedLessons(country: country, language: language).value
        )
        
        return try await getPersistedResources(personalizedLessons: personalizedLessons)
    }
    
    func getPersistedDefaultOrderLessons(language: String) async throws -> [ResourceDataModel] {
        
        let personalizedLessons: PersonalizedLessonsDataModel? = try persistence.getDataModel(
            id: PersonalizedLessonsId.createForDefaultOrder(language: language).value
        )
        
        return try await getPersistedResources(personalizedLessons: personalizedLessons)
    }
    
    private func getPersistedResources(personalizedLessons: PersonalizedLessonsDataModel?) async throws -> [ResourceDataModel] {
        
        guard let personalizedLessons = personalizedLessons else {
            return Array()
        }
        
        return try await resourcesRepository.persistence.getDataModelsAsync(getOption: .objectsByIds(ids: personalizedLessons.resourceIds))
    }
}

// MARK: - Sync

extension PersonalizedLessonsRepository {
    
    func syncPersonalizedLessonsPublisher(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) -> AnyPublisher<[ResourceDataModel], Error> {

        return AnyPublisher() {
            
            return try await self.syncPersonalizedLessons(
                requestPriority: requestPriority,
                country: country,
                language: language,
                forceNewSync: forceNewSync
            )
        }
    }
    
    private func syncPersonalizedLessons(requestPriority: RequestPriority, country: String?, language: String, forceNewSync: Bool = false) async throws -> [ResourceDataModel] {
        
        let type = PersonalizedLessonsType(country: country, langauge: language)
        
        let personalizedLessonId = try PersonalizedLessonsId(type: type)
        
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(
            id: personalizedLessonId
        )
        
        let shouldSync: Bool = syncInvalidator.shouldSync || forceNewSync
        
        guard shouldSync else {
            
            switch type {
            
            case .allRanked(let country, let language):
                return try await getPersistedAllRankedLessons(country: country, language: language)
            
            case .defaultOrder(let language):
                return try await getPersistedDefaultOrderLessons(language: language)
            }
        }
        
        let resourceCodables: [ResourceCodable]
        
        switch type {
        
        case .allRanked(let country, let language):
            resourceCodables = try await api.getAllRankedResources(
                requestPriority: requestPriority,
                country: country,
                language: language,
                resourceType: .lesson
            )
        
        case .defaultOrder(let language):
            resourceCodables = try await api.getDefaultOrderResources(
                requestPriority: requestPriority,
                language: language,
                resourceType: .lesson
            )
        }
        
        let personalizedLessons = try PersonalizedLessonsDataModel(
            country: country,
            language: language,
            resourceIds: resourceCodables.map { $0.id }
        )
        
        _ = try await persistence.writeObjectsAsync(
            externalObjects: [personalizedLessons],
            writeOption: nil,
            getOption: nil
        )
        
        syncInvalidator.didSync()
        
        return try await getPersistedResources(personalizedLessons: personalizedLessons)
    }
}
