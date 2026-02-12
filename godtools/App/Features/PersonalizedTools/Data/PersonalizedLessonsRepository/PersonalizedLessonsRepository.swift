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

final class PersonalizedLessonsRepository {

    private let api: PersonalizedToolsApi
    private let cache: PersonalizedLessonsCache

    private var cancellables: Set<AnyCancellable> = Set()

    init(api: PersonalizedToolsApi, cache: PersonalizedLessonsCache) {

        self.api = api
        self.cache = cache
    }

    @MainActor func getPersonalizedLessonsChanged(reloadFromRemote: Bool, requestPriority: RequestPriority, country: String?, language: String) -> AnyPublisher<Void, Never> {

        if reloadFromRemote {

            getAllRankedLessonsPublisher(requestPriority: requestPriority, country: country, language: language)
                .sink { _ in

                } receiveValue: { _ in

                }
                .store(in: &cancellables)
        }

        return cache.getPersonalizedLessonsChanged()
    }

    func getPersonalizedLessons(country: String?, language: String) -> PersonalizedLessonsDataModel? {

        return cache.getPersonalizedLessonsFor(country: country, language: language)
    }

    private func getAllRankedLessonsPublisher(requestPriority: RequestPriority, country: String?, language: String) -> AnyPublisher<[PersonalizedLessonsDataModel], Error> {

        let publisher: AnyPublisher<[ResourceCodable], Error>

        if let country = country, !country.isEmpty {
            publisher = api.getAllRankedResourcesPublisher(requestPriority: requestPriority, country: country, language: language, resourceType: .lesson)
        } else {
            publisher = api.getDefaultOrderResourcesPublisher(requestPriority: requestPriority, language: language, resouceType: .lesson)
        }

        return publisher
            .flatMap { (resourceCodables: [ResourceCodable]) in

                let resources: [ResourceDataModel] = resourceCodables.map {
                    ResourceDataModel(interface: $0)
                }

                let personalizedLessons = PersonalizedLessonsDataModel(
                    country: country,
                    language: language,
                    resourceIds: resources.map { $0.id }
                )

                return self.cache.syncPersonalizedLessons([personalizedLessons])
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
