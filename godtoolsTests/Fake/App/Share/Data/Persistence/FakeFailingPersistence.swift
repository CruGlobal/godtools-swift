//
//  FakeFailingPersistence.swift
//  godtools
//
//  Created by Rachael Skeath on 9/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import RepositorySync

enum FakeFailingPersistenceError: Error {
    case persistenceUnavailable
}

final class FakeFailingPersistence<DataModelType: Sendable, ExternalObjectType: Sendable>: Persistence {
    
    init() {
        
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        
        return Fail(error: FakeFailingPersistenceError.persistenceUnavailable)
            .eraseToAnyPublisher()
    }
    
    func getObjectCount() throws -> Int {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func getDataModel(id: String) throws -> DataModelType? {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func getDataModels() async throws -> [DataModelType] {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func getDataModels(getOption: PersistenceGetOption) async throws -> [DataModelType] {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func writeObjects(externalObjects: [ExternalObjectType]) async throws {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func writeObjects(externalObjects: [ExternalObjectType], writeOption: PersistenceWriteOption?, getOption: PersistenceGetOption?) async throws -> [DataModelType] {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func deleteCollection() async throws {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
    
    func deleteObjectsByIds(ids: Set<String>, getOption: PersistenceGetOption?) async throws -> [DataModelType] {
        throw FakeFailingPersistenceError.persistenceUnavailable
    }
}
