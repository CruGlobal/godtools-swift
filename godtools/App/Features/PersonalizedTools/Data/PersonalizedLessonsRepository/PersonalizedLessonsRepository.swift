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

    func getPersonalizedLessons(country: String, language: String) -> PersonalizedLessonsDataModel? {

        let id: String = PersonalizedLessonsId(country: country, language: language).value
        
        let dataModel: PersonalizedLessonsDataModel? = persistence
            .getDataModelNonThrowing(id: id)
        
        return dataModel
    }

    func syncAllRankedLessonsPublisher(requestPriority: RequestPriority, country: String, language: String, forceNewSync: Bool = false) -> AnyPublisher<PersonalizedLessonsDataModel?, Error> {

        let syncInvalidator: SyncInvalidator = getSyncInvalidator(id: PersonalizedLessonsId(country: country, language: language))
        
        let shouldSync: Bool = syncInvalidator.shouldSync || forceNewSync
        
        guard shouldSync else {
            
            return Just(getPersonalizedLessons(country: country, language: language))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return api
            .getAllRankedResourcesPublisher(
                requestPriority: requestPriority,
                country: country,
                language: language,
                resourceType: .lesson
            )
            .flatMap { (resourceCodables: [ResourceCodable]) in

                let resources: [ResourceDataModel] = resourceCodables.map {
                    ResourceDataModel(interface: $0)
                }

                let personalizedLessons = PersonalizedLessonsDataModel(
                    country: country,
                    language: language,
                    resourceIds: resources.map { $0.id }
                )
                
                return self.persistence
                    .writeObjectsPublisher(
                        externalObjects: [personalizedLessons],
                        writeOption: nil,
                        getOption: .object(id: personalizedLessons.id)
                    )
                    .eraseToAnyPublisher()
            }
            .map { (personalizedLessons: [PersonalizedLessonsDataModel]) in
                
                syncInvalidator.didSync()
                
                return personalizedLessons.first
            }
            .eraseToAnyPublisher()
    }
}
