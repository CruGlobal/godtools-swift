//
//  LocalUserCounterIncrement.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import SwiftData
import RealmSwift

final class LocalUserCounterIncrement {
    
    private let persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
    
    init(persistence: any Persistence<UserCounterDataModel, UserCounterCodable>) {

        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, SwiftUserCounter>? {
        return persistence as? SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, SwiftUserCounter>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>? {
        return persistence as? RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>
    }
}

extension LocalUserCounterIncrement {
    
    private func fetchAndIncrementCounter(id: String) throws -> UserCounterCodable {
        
        guard let counter = try persistence.getDataModel(id: id) else {
            
            let count: Int = 1
            
            return UserCounterCodable(
                id: id,
                count: count,
                localCount: count
            )
        }
        
        let count: Int = counter.count + 1
        
        return UserCounterCodable(
            id: id,
            count: count,
            localCount: count
        )
    }
    
    func incrementCounter(id: String) async throws -> UserCounterDataModel {
        
        let updatedCounter: UserCounterCodable = try fetchAndIncrementCounter(id: id)
        
        _ = try await persistence.writeObjectsAsync(
            externalObjects: [updatedCounter],
            writeOption: nil,
            getOption: nil
        )
        
        return UserCounterDataModel(interface: updatedCounter)
    }
    
    func getCounter(id: String) throws -> UserCounterDataModel? {
        
        return try persistence.getDataModel(id: id)
    }
    
    func getCounters() async throws -> [UserCounterDataModel] {
        
        return try await persistence.getDataModelsAsync(getOption: .allObjects)
    }
    
    func deleteCounters() async throws {
                
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let counters: [SwiftUserCounter] = try database.read.objects(context: context, query: nil)
            
            guard counters.count > 0 else {
                return
            }
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(
                    deleteObjects: counters,
                    insertObjects: nil
                )
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let counters: [RealmUserCounter] = database.read.objects(realm: realm, query: nil)
            
            guard counters.count > 0 else {
                return
            }
            
            try database.write.realm(
                realm: realm,
                writeClosure: { (realm: Realm) in
                    
                    return WriteRealmObjects(
                        deleteObjects: counters,
                        addObjects: nil
                    )
                },
                updatePolicy: .modified
            )
        }
    }
}
