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
    
    struct TestArgument {
        let swiftDatabaseName: String = "RepositorySyncTests_swift_" + UUID().uuidString
        let initialPersistedObjectsIds: [String]
        let externalObjectIds: [String]
        let expectedDataModelIds: [String]
    }
    
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
        
        let count: Int = persistence.getObjectCount()
        
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
    
    // MARK: - Write Tests
    
    @available(iOS, introduced: 17.0)
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: ["1", "0", "9", "8"],
            expectedDataModelIds: ["0", "1", "2", "3", "4", "5", "6", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalObjectIds: ["3", "2", "1", "8", "9"],
            expectedDataModelIds: ["1", "2", "3", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: ["2", "1"],
            expectedDataModelIds: ["0", "1", "2", "3", "4", "5", "6"]
        )
        ,
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: [],
            expectedDataModelIds: ["0", "1", "2", "3", "4", "5", "6"]
        )
    ])
    @MainActor func writesExternalObjects(argument: TestArgument) async {
                
        let persistence = Self.getPersistence(
            swiftDatabaseName: argument.swiftDatabaseName,
            addObjectsByIds: argument.initialPersistedObjectsIds
        )
        
        let externalObjects: [MockRepositorySyncDataModel] = MockRepositorySyncDataModel.getDataModelsFromIds(ids: argument.externalObjectIds)
        
        let writtenObjects: [MockRepositorySyncDataModel] = persistence.writeObjects(
            externalObjects: externalObjects,
            deleteObjectsNotFoundInExternalObjects: false
        )
                
        #expect(writtenObjects.count == externalObjects.count)
        #expect(argument.externalObjectIds.sorted { $0 < $1 } == MockRepositorySyncDataModel.sortDataModelIds(dataModels: writtenObjects))
        #expect(argument.expectedDataModelIds == MockRepositorySyncDataModel.sortDataModelIds(dataModels: persistence.getObjects()))
        
        Self.deleteSwiftDatabase(name: argument.swiftDatabaseName)
    }
    
    @available(iOS, introduced: 17.0)
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: ["1", "0", "9", "8"],
            expectedDataModelIds: ["0", "1", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalObjectIds: ["3", "2", "1", "8", "9"],
            expectedDataModelIds: ["1", "2", "3", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: ["2", "1"],
            expectedDataModelIds: ["1", "2"]
        )
        ,
        TestArgument(
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalObjectIds: [],
            expectedDataModelIds: []
        )
    ])
    @MainActor func writesExternalObjectsAndDeletesNonExistingExternalObjects(argument: TestArgument) async {
                
        let persistence = Self.getPersistence(
            swiftDatabaseName: argument.swiftDatabaseName,
            addObjectsByIds: argument.initialPersistedObjectsIds
        )
        
        let externalObjects: [MockRepositorySyncDataModel] = MockRepositorySyncDataModel.getDataModelsFromIds(ids: argument.externalObjectIds)
        
        let writtenObjects: [MockRepositorySyncDataModel] = persistence.writeObjects(
            externalObjects: externalObjects,
            deleteObjectsNotFoundInExternalObjects: true
        )
                
        #expect(writtenObjects.count == externalObjects.count)
        #expect(persistence.getObjectCount() == writtenObjects.count)
        #expect(argument.expectedDataModelIds == MockRepositorySyncDataModel.sortDataModelIds(dataModels: writtenObjects))
        #expect(argument.expectedDataModelIds == MockRepositorySyncDataModel.sortDataModelIds(dataModels: persistence.getObjects()))
        
        Self.deleteSwiftDatabase(name: argument.swiftDatabaseName)
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
    
    static func getDataModelMapping() -> any RepositorySyncMapping<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncSwiftDataObject> {
        
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
    
    private static func getSwiftDatabase(name: String) -> SwiftDatabase {
        
        let swiftDatabase = SwiftDatabase(
            config: getSwiftDatabaseConfiguration(name: name),
            schema: Schema(versionedSchema: MockSwiftDataSchemaV1.self),
            migrationPlan: nil
        )
        
        return swiftDatabase
    }
    
    static func getSwiftDatabase(name: String, addObjects: [any IdentifiableSwiftDataObject]) -> SwiftDatabase {
        
        let swiftDatabase: SwiftDatabase = Self.getSwiftDatabase(name: name)
        
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
        
        let swiftDatabase: SwiftDatabase = Self.getSwiftDatabase(name: name)
        
        swiftDatabase.deleteAllObjects()
    }
}
