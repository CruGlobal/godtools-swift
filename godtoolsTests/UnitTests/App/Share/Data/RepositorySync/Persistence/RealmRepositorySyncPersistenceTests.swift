//
//  RealmRepositorySyncPersistenceTests.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift

struct RealmRepositorySyncPersistenceTests {

    struct TestArgument {
        let realmFileName: String = "RepositorySyncTests_realm_" + UUID().uuidString
        let initialPersistedObjectsIds: [String]
        let externalObjectIds: [String]
        let expectedDataModelIds: [String]
    }
    
    // MARK: - Read Tests
    
    @Test()
    @MainActor func returnsCorrectNumberOfObjects() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                    
        let persistence = Self.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let count: Int = persistence.getObjectCount()
        
        Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
        #expect(count == initialPersistedObjectsIds.count)
    }
    
    @Test()
    @MainActor func fetchesObjectById() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                
        let persistence = Self.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let objectIdToFetch: String = "0"
        
        let dataModel: MockRepositorySyncDataModel? = persistence.getObject(id: objectIdToFetch)
        
        Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
        #expect(dataModel?.id == objectIdToFetch)
    }
    
    @Test()
    @MainActor func fetchesAllObjects() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
                    
        let persistence = Self.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let dataModels: [MockRepositorySyncDataModel] = persistence.getObjects()
        
        let sortedDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: dataModels)
        
        Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
        #expect(sortedDataModelIds == ["0", "1", "2", "3", "4", "5", "6"])
    }
    
    @Test()
    @MainActor func fetchesObjectsByIds() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
        
        let persistence = Self.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let ids: [String] = ["0", "1", "2"]
        let dataModels: [MockRepositorySyncDataModel] = persistence.getObjects(ids: ids)
        
        Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
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
            realmFileName: argument.realmFileName,
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
        
        Self.deleteRealmDatabaseFile(fileName: argument.realmFileName)
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
            realmFileName: argument.realmFileName,
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
        
        Self.deleteRealmDatabaseFile(fileName: argument.realmFileName)
    }
    
    // MARK: - Delete Tests
    
    @Test()
    @MainActor func allObjectsDeleted() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
        
        let persistence = Self.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
                
        #expect(persistence.getObjects().count == initialPersistedObjectsIds.count)
        
        persistence.deleteAllObjects()
        
        #expect(persistence.getObjects().count == 0)
        
        Self.deleteRealmDatabaseFile(fileName: realmFileName)
    }
}

// MARK: - Persistence

extension RealmRepositorySyncPersistenceTests {
    
    static func getPersistence(realmFileName: String, addObjectsByIds: [String]) -> RealmRepositorySyncPersistence<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncRealmObject> {
        
        return RealmRepositorySyncPersistence(
            realmDatabase: getRealmDatabase(
                fileName: realmFileName,
                addObjects: getObjectsFromIds(ids: addObjectsByIds)
            ),
            dataModelMapping: getDataModelMapping()
        )
    }
    
    static func getDataModelMapping() -> RealmRepositorySyncMapping<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncRealmObject> {
        
        return MockRealmRepositorySyncMapping()
    }
    
    static func getObjectsFromIds(ids: [String]) -> [MockRepositorySyncRealmObject] {
        
        let initialObjects: [MockRepositorySyncRealmObject] = ids.map {
            let object = MockRepositorySyncRealmObject()
            object.id = $0
            object.name = "name_" + $0
            return object
        }
        
        return initialObjects
    }
}

// MARK: - RealmDatabase

extension RealmRepositorySyncPersistenceTests {
    
    static func getRealmDatabaseConfiguration(fileName: String) -> RealmDatabaseConfiguration {
        
        return RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: fileName,
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    }
    
    static func getRealmDatabase(fileName: String, addObjects: [Object]) -> RealmDatabase {
        
        let realmDatabase: RealmDatabase = RealmDatabase(
            databaseConfiguration: Self.getRealmDatabaseConfiguration(fileName: fileName)
        )
                
        if addObjects.count > 0 {
            
            let realm: Realm = realmDatabase.openRealm()
            
            do {
                try realm.write {
                    realm.add(addObjects, update: .all)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }

        return realmDatabase
    }
    
    static func deleteRealmDatabaseFile(fileName: String) {
        
        DispatchQueue.main.async {
            
            let databaseConfiguration: RealmDatabaseConfiguration = Self.getRealmDatabaseConfiguration(
                fileName: fileName
            )
            
            do {
                _ = try Realm.deleteFiles(for: databaseConfiguration.getRealmConfig())
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}
