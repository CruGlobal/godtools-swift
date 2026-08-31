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
    
    func sync(
        requestPriority: RequestPriority,
        country: String?,
        language: String,
        forceNewSync: Bool
    ) async throws {
        
        var types: [PersonalizedToolsType] = [
            .defaultOrder(language: language)
        ]
        
        if let country = country {
            types.append(.featured(country: country, language: language))
            types.append(.ranked(country: country, language: language))
        }
        
        try await syncTypes(requestPriority: requestPriority, types: types, forceNewSync: forceNewSync)
    }
    
    func syncTypes(
        requestPriority: RequestPriority,
        types: [PersonalizedToolsType],
        forceNewSync: Bool
    ) async throws {

        try await withThrowingTaskGroup(of: Void.self) { group in

            for type in types {

                group.addTask {

                    try await self.syncType(
                        requestPriority: requestPriority,
                        type: type,
                        forceNewSync: forceNewSync
                    )
                }
            }

            try await group.waitForAll()
        }
    }
    
    func syncType(
        requestPriority: RequestPriority,
        type: PersonalizedToolsType,
        forceNewSync: Bool
    ) async throws {

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

        case .defaultOrder(let language):
            resourceCodables = try await api.getDefaultOrderResources(
                requestPriority: requestPriority,
                language: language,
                resourceTypes: nil
            )
            
        case .featured(let country, let language):
            resourceCodables = try await api.getFeaturedResources(
                requestPriority: requestPriority,
                country: country,
                language: language,
                resourceTypes: nil
            )
            
        case .ranked(let country, let language):
            resourceCodables = try await api.getRankedResources(
                requestPriority: requestPriority,
                country: country,
                language: language,
                resourceTypes: nil
            )
        }
        
        let dataModel = try PersonalizedToolsDataModel(
            type: type,
            resourceIds: resourceCodables.map { $0.id }
        )

        _ = try await cache.persistence.writeObjects(externalObjects: [dataModel])

        await syncInvalidator.didSync()
    }
}
