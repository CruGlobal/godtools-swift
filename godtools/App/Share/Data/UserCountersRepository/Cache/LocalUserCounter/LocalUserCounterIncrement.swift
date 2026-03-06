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
    
    private func fetchAndIncrementCounter(id: String) throws -> LocalUserCounter {
        
        let currentLocalCount: Int?
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let swiftCounter: SwiftUserCounter? = try database.read.object(context: context, id: id)
            
            currentLocalCount = swiftCounter?.localCount
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let realmCounter: RealmUserCounter? = database.read.object(realm: realm, id: id)
            
            currentLocalCount = realmCounter?.localCount
        }
        else {
            
            currentLocalCount = nil
        }
        
        let initialCount: Int = 0
        
        var clampedLocalCount: Int = initialCount
        
        if let currentLocalCount = currentLocalCount, currentLocalCount < 0 {
            clampedLocalCount = initialCount
        }
        else {
            clampedLocalCount = currentLocalCount ?? initialCount
        }
        
        let newLocalCount: Int = clampedLocalCount + 1
        
        return LocalUserCounter(
            id: id,
            localCount: newLocalCount
        )
    }
    
    func incrementCounter(id: String) throws -> LocalUserCounter {
        
        let updatedCounter: LocalUserCounter = try fetchAndIncrementCounter(id: id)
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let counter: SwiftUserCounter = try database.read.object(context: context, id: id) ?? SwiftUserCounter()
            
            counter.id = id
            counter.localCount = updatedCounter.localCount
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: [counter])
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let counter: RealmUserCounter
            
            let existingCounter: RealmUserCounter? = database.read.object(realm: realm, id: id)
            
            if let existingCounter = existingCounter {
                counter = existingCounter
            }
            else {
                counter = RealmUserCounter()
                counter.id = id
            }

            try database.write.realm(
                realm: realm,
                writeClosure: { realm in
                    
                    counter.localCount = updatedCounter.localCount
                    
                    return WriteRealmObjects(deleteObjects: nil, addObjects: [counter])
                },
                updatePolicy: .modified
            )
        }
        
        return LocalUserCounter(
            id: id,
            localCount: updatedCounter.localCount
        )
    }
    
    func getCounter(id: String) throws -> LocalUserCounter? {
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let swiftCounter: SwiftUserCounter? = try database.read.object(context: context, id: id)
            
            if let swiftCounter = swiftCounter {
                return LocalUserCounter(id: id, localCount: swiftCounter.localCount)
            }
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let realmCounter: RealmUserCounter? = database.read.object(realm: realm, id: id)
            
            if let realmCounter = realmCounter {
                return LocalUserCounter(id: id, localCount: realmCounter.localCount)
            }
        }
        
        return nil
    }
    
    func getCounters() throws -> [LocalUserCounter] {
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let counters: [SwiftUserCounter] = try database.read.objects(context: context, query: nil)
            
            return counters.map {
                LocalUserCounter(id: $0.id, localCount: $0.localCount)
            }
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let counters: [RealmUserCounter] = database.read.objects(realm: realm, query: nil)
            
            return counters.map {
                LocalUserCounter(id: $0.id, localCount: $0.localCount)
            }
        }
        
        return Array()
    }
    
    func decrementCount(id: String, decrementBy: Int) throws {
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let swiftCounter: SwiftUserCounter? = try database.read.object(context: context, id: id)
            
            guard let swiftCounter = swiftCounter else {
                return
            }
            
            swiftCounter.localCount -= decrementBy
            
            if swiftCounter.localCount < 0 {
                swiftCounter.localCount = 0
            }
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: [swiftCounter])
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let realmCounter: RealmUserCounter? = database.read.object(realm: realm, id: id)
            
            guard let realmCounter = realmCounter else {
                return
            }
            
            try database.write.realm(
                realm: realm,
                writeClosure: { realm in
                    
                    realmCounter.localCount -= decrementBy
                    
                    if realmCounter.localCount < 0 {
                        realmCounter.localCount = 0
                    }
                    
                    return WriteRealmObjects(deleteObjects: nil, addObjects: [realmCounter])
                },
                updatePolicy: .modified
            )
        }
    }
}
