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

    private var cancellables: Set<AnyCancellable> = Set()

    init(persistence: any Persistence<PersonalizedLessonsDataModel, PersonalizedLessonsDataModel>, api: PersonalizedToolsApi, cache: PersonalizedLessonsCache) {

        self.api = api
        self.cache = cache
        
        super.init(
            externalDataFetch: NoExternalDataFetch<PersonalizedLessonsDataModel>(),
            persistence: persistence
        )
    }

    @MainActor func getPersonalizedLessonsChanged(reloadFromRemote: Bool, requestPriority: RequestPriority, country: String, language: String) -> AnyPublisher<Void, Error> {

        if reloadFromRemote {

            getAllRankedLessonsPublisher(requestPriority: requestPriority, country: country, language: language)
                .sink { _ in

                } receiveValue: { _ in

                }
                .store(in: &cancellables)
        }

        return persistence
            .observeCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }

    func getPersonalizedLessons(country: String, language: String) -> PersonalizedLessonsDataModel? {

        let id: String = PersonalizedLessonsId(country: country, language: language).value
        
        return persistence
            .getDataModelNonThrowing(id: id)
    }

    private func getAllRankedLessonsPublisher(requestPriority: RequestPriority, country: String, language: String) -> AnyPublisher<[PersonalizedLessonsDataModel], Error> {

        return api
            .getAllRankedResourcesPublisher(requestPriority: requestPriority, country: country, language: language, resourceType: .lesson)
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
            .eraseToAnyPublisher()
    }
}
