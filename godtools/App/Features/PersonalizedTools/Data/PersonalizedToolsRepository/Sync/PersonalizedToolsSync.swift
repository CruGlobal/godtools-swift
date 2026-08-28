//
//  PersonalizedToolsSync.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PersonalizedToolsSync: Sendable {
    
    private let api: PersonalizedToolsApiInterface
    private let cache: PersonalizedToolsCache
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
            
    init(
        api: PersonalizedToolsApiInterface,
        cache: PersonalizedToolsCache,
        syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    ) {

        self.api = api
        self.cache = cache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
    }
    
    private func getSyncInvalidator(id: PersonalizedToolsId) -> SyncInvalidator {

        let id: String = "\(String(describing: PersonalizedToolsRepository.self)).syncPersonalizedTools.\(id.value)"

        return SyncInvalidator(
            id: id,
            timeInterval: .hours(hour: 8),
            persistence: syncInvalidatorPersistence
        )
    }
    
    func syncPersonalizedTools(
        requestPriority: RequestPriority,
        country: String?,
        language: String,
        forceNewSync: Bool
    ) async throws {

        let type = PersonalizedToolsType(country: country, language: language)

        let personalizedToolId = try PersonalizedToolsId(type: type)

        let syncInvalidator: SyncInvalidator = getSyncInvalidator(
            id: personalizedToolId
        )
        
        let shouldSync: Bool = await syncInvalidator.shouldSync || forceNewSync

        guard shouldSync else {
            return
        }
                
        let resourceCodables: [ResourceCodable]

        switch type {

        case .allRanked(let country, let language):
            resourceCodables = try await api.getRankedResources(
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

        _ = try await cache.persistence.writeObjects(externalObjects: [personalizedTools])

        await syncInvalidator.didSync()
    }
}
