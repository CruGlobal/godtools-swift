//
//  UserCountersCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift
import SwiftData

final class UserCountersCache {
    
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

extension UserCountersCache {
    
    func writeCounters(counters: [UserCounterCodable]) throws {
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            var countersToWrite: [SwiftUserCounter] = Array()
            
            for counter in counters {
                
                let swiftCounter: SwiftUserCounter = try database.read.object(context: context, id: counter.id) ?? SwiftUserCounter()
                
                swiftCounter.mapFrom(model: counter.toModel())
                
                countersToWrite.append(swiftCounter)
            }
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: countersToWrite)
            )
        }
        else if let database = getRealmPersistence()?.database {
                        
            var countersToWrite: [RealmUserCounter] = Array()
            
            database.write.async { (realm: Realm) in
                
                for counter in counters {
                    
                    let realmUserCounter: RealmUserCounter
                    
                    let existingCounter: RealmUserCounter? = database.read.object(realm: realm, id: counter.id)
                    
                    if let existingCounter = existingCounter {
                        realmUserCounter = existingCounter
                    }
                    else {
                        realmUserCounter = RealmUserCounter()
                        realmUserCounter.id = counter.id
                    }
                    
                    realmUserCounter.count = counter.count
                    
                    countersToWrite.append(realmUserCounter)
                }
                
                realm.add(countersToWrite, update: .modified)
                
            } writeError: { error in
                
            }
        }
    }
    
    func deleteCounters() throws {
                
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
