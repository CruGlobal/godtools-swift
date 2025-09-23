//
//  SwiftRepositorySyncPersistenceTests.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData

struct SwiftRepositorySyncPersistenceTests {
    
    // MARK: - Read Tests
    
    @available(iOS, introduced: 17.0)
    @Test()
    @MainActor func returnsCorrectNumberOfObjects() async {
        
        let swiftDatabaseName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                    
        let persistence = Self.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let count: Int = persistence.getCount()
        
        Self.deleteSwiftDatabase(name: swiftDatabaseName)
        
        #expect(count == initialPersistedObjectsIds.count)
    }
    
    @available(iOS, introduced: 17.0)
    @Test()
    @MainActor func fetchesObjectById() async {
        
        let swiftDatabaseName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                
        let persistence = Self.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let objectIdToFetch: String = "0"
        
        let dataModel: MockRepositorySyncDataModel? = persistence.getObject(id: objectIdToFetch)
        
        Self.deleteSwiftDatabase(name: swiftDatabaseName)
        
        #expect(dataModel?.id == objectIdToFetch)
    }
    
    @available(iOS, introduced: 17.0)
    @Test()
    @MainActor func fetchesAllObjects() async {
        
        let swiftDatabaseName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                    
        let persistence = Self.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let dataModels: [MockRepositorySyncDataModel] = persistence.getObjects()
        
        let sortedDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: dataModels)
                    
        Self.deleteSwiftDatabase(name: swiftDatabaseName)
        
        #expect(sortedDataModelIds == ["0", "1", "2", "3", "4", "5", "6"])
    }
    
    @available(iOS, introduced: 17.0)
    @Test()
    @MainActor func fetchesObjectsByIds() async {
        
        let swiftDatabaseName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
        
        let persistence = Self.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let ids: [String] = ["0", "1", "2"]
        let dataModels: [MockRepositorySyncDataModel] = persistence.getObjects(ids: ids)
        
        Self.deleteSwiftDatabase(name: swiftDatabaseName)
        
        #expect(ids.count == dataModels.count)
        #expect(dataModels.count(where: {$0.id == "0"}) == 1)
        #expect(dataModels.count(where: {$0.id == "1"}) == 1)
        #expect(dataModels.count(where: {$0.id == "2"}) == 1)
    }
    
    // MARK: - Delete Tests
    
    @available(iOS, introduced: 17.0)
    @Test()
    @MainActor func allObjectsDeleted() async {
        
        let swiftDatabaseName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
        
        let persistence = Self.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
                
        #expect(persistence.getObjects().count == initialPersistedObjectsIds.count)
        
        persistence.deleteAllObjects()
        
        #expect(persistence.getObjects().count == 0)
        
        Self.deleteSwiftDatabase(name: swiftDatabaseName)
    }
}

// MARK: - Persistence

@available(iOS 17, *)
extension SwiftRepositorySyncPersistenceTests {
    
    static func getPersistence(swiftDatabaseName: String, addObjectsByIds: [String]) -> SwiftRepositorySyncPersistence<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncSwiftDataObject> {
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: getSwiftDatabase(
                name: swiftDatabaseName,
                addObjects: getObjectsFromIds(ids: addObjectsByIds)
            ),
            dataModelMapping: getDataModelMapping()
        )
    }
    
    static func getDataModelMapping() -> RepositorySyncMapping<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncSwiftDataObject> {
        
        return MockRepositorySyncMapping()
    }
    
    static func getObjectsFromIds(ids: [String]) -> [MockRepositorySyncSwiftDataObject] {
        
        let initialObjects: [MockRepositorySyncSwiftDataObject] = ids.map {
            let object = MockRepositorySyncSwiftDataObject()
            object.id = $0
            object.name = "name_" + $0
            return object
        }
        
        return initialObjects
    }
}

// MARK: - SwiftDatabase

@available(iOS 17, *)
extension SwiftRepositorySyncPersistenceTests {
    
    static func getSwiftDatabaseConfiguration(name: String) -> SwiftDatabaseConfiguration {
        
        return SwiftDatabaseConfiguration(modelConfiguration: ModelConfiguration(
            name,
            schema: nil,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        ))
    }
    
    static func getSwiftDatabase(name: String, addObjects: [any IdentifiableSwiftDataObject]) -> SwiftDatabase {
        
        let swiftDatabase: SwiftDatabase = SwiftDatabase(
            configuration: getSwiftDatabaseConfiguration(name: name),
            modelTypes: MockRepositorySyncSwiftDataModelTypes()
        )
        
        let context: ModelContext = swiftDatabase.openContext()
        
        for object in addObjects {
            context.insert(object)
        }
        
        do {
            try context.save()
        }
        catch let error {
            assertionFailure(error.localizedDescription)
        }

        return swiftDatabase
    }
    
    static func deleteSwiftDatabase(name: String) {
        
        SwiftDatabase(
            configuration: getSwiftDatabaseConfiguration(name: name),
            modelTypes: MockRepositorySyncSwiftDataModelTypes()
        ).deleteAllData()
    }
}
