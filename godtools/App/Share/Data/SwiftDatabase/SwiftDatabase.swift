//
//  SwiftDatabase.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
class SwiftDatabase {
    
    private let container: ModelContainer
    
    let configName: String
    
    init(config: SwiftDatabaseConfigInterface, schema: Schema, migrationPlan: (any SchemaMigrationPlan.Type)?) {
                
        do {
            
            container = try Self.createContainer(
                config: config,
                schema: schema,
                migrationPlan: migrationPlan
            )
        }
        catch let error {
            
            assertionFailure("\n SwiftData init container error: \(error.localizedDescription)")
            
            container = try! Self.createContainer(
                config: InMemorySwiftDatabaseConfig(),
                schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self),
                migrationPlan: nil
            )
        }
        
        configName = config.modelConfiguration.name
    }
    
    private static func createContainer(config: SwiftDatabaseConfigInterface, schema: Schema, migrationPlan: (any SchemaMigrationPlan.Type)?) throws -> ModelContainer {
        
        return try ModelContainer(
            for: schema,
            migrationPlan: migrationPlan,
            configurations: config.modelConfiguration
        )
    }
    
    func openContext() -> ModelContext {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return context
    }
}

@available(iOS 17.4, *)
extension SwiftDatabase {
    
    func getFetchDescriptor<T: IdentifiableSwiftDataObject>(query: SwiftDatabaseQuery<T>?) -> FetchDescriptor<T> {
        
        return query?.fetchDescriptor ?? FetchDescriptor<T>()
    }
    
    func getObjectCount<T: IdentifiableSwiftDataObject>(query: SwiftDatabaseQuery<T>?) -> Int {
        
        do {
            return try openContext()
                .fetchCount(
                    getFetchDescriptor(query: query)
                )
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return 0
        }
    }
    
    func getObject<T: IdentifiableSwiftDataObject>(context: ModelContext, id: String) -> T? {
        
        let idPredicate = #Predicate<T> { object in
            object.id == id
        }
        
        let query = SwiftDatabaseQuery.filter(filter: idPredicate)
        
        return getObjects(context: context, query: query).first
    }
    
    func getObjects<T: IdentifiableSwiftDataObject>(context: ModelContext, ids: [String]) -> [T] {
        
        let filter = #Predicate<T> { object in
            ids.contains(object.id)
        }
        
        let query = SwiftDatabaseQuery.filter(filter: filter)
        
        return getObjects(context: context, query: query)
    }
    
    func getObjects<T: IdentifiableSwiftDataObject>(context: ModelContext, query: SwiftDatabaseQuery<T>?) -> [T] {
        
        let objects: [T]
        
        do {
            objects = try context.fetch(getFetchDescriptor(query: query))
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            objects = Array()
        }
        
        return objects
    }
    
    func saveObjects(context: ModelContext, objectsToAdd: [any PersistentModel], objectsToRemove: [any PersistentModel]) throws {
        
        for object in objectsToAdd {
            context.insert(object)
        }
        
        for object in objectsToRemove {
            context.delete(object)
        }
        
        guard context.hasChanges else {
            return
        }
                
        do {
            try context.save()
        }
        catch let error {
            throw error
        }
    }
    
    func deleteAllObjects() {
        
        if #available(iOS 18, *) {
            do {
                try container.erase()
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }
        else {
            container.deleteAllData()
        }
    }
}
