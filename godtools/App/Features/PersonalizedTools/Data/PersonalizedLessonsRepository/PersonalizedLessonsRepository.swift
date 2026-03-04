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

    private var cancellables: Set<AnyCancellable> = Set()

    init(persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>, api: PersonalizedToolsApi, cache: PersonalizedLessonsCache, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface) {

        self.api = api
        self.cache = cache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        
        super.init(
            externalDataFetch: NoExternalDataFetch<PersonalizedLessonsDataModel>(),
            persistence: persistence
        )
    }
    
    private func getSyncInvalidator(id: PersonalizedLessonsId) -> SyncInvalidator {
        
        return SyncInvalidator(
            id: id.value,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
    }

    @MainActor func getPersonalizedLessonsChanged(requestPriority: RequestPriority, country: String, language: String, forceNewSync: Bool = false) -> AnyPublisher<Void, Error> {

        syncAllRankedLessonsPublisher(
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

    func getPersonalizedLessons(country: String, language: String) throws -> PersonalizedLessonsDataModel? {

        let id: String = PersonalizedLessonsId(country: country, language: language).value
        
        return try persistence.getDataModel(id: id)
    }

    func syncAllRankedLessonsPublisher(requestPriority: RequestPriority, country: String, language: String, forceNewSync: Bool = false) -> AnyPublisher<PersonalizedLessonsDataModel?, Error> {

        return AnyPublisher() {
            
            return try await self.syncAllRankedLessons(
                requestPriority: requestPriority,
                country: country,
                language: language,
                forceNewSync: forceNewSync
            )
        }
    }
    
    private func syncAllRankedLessons(requestPriority: RequestPriority, country: String, language: String, forceNewSync: Bool = false) async throws -> PersonalizedLessonsDataModel? {
        
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(id: PersonalizedLessonsId(country: country, language: language))
        
        let shouldSync: Bool = syncInvalidator.shouldSync || forceNewSync
        
        guard shouldSync else {
            return try getPersonalizedLessons(country: country, language: language)
        }
        
        let resourceCodables: [ResourceCodable] = try await api.getAllRankedResources(
            requestPriority: requestPriority,
            country: country,
            language: language,
            resourceType: .lesson
        )

        let personalizedLessons = PersonalizedLessonsDataModel(
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
        
        return personalizedLessons
    }
}
