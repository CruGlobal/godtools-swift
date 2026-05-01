//
//  LocalActivityCounterCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftData
import RepositorySync

final class LocalActivityCounterCache {
    
    let persistence: any Persistence<LocalActivityCountDataModel, LocalActivityCountDataModel>
    
    init(persistence: any Persistence<LocalActivityCountDataModel, LocalActivityCountDataModel>) {

        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, SwiftLocalActivityCount>? {
        return persistence as? SwiftRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, SwiftLocalActivityCount>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, RealmLocalActivityCount>? {
        return persistence as? RealmRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, RealmLocalActivityCount>
    }
}

extension LocalActivityCounterCache {
    
    func getCounter(id: String) throws -> LocalActivityCountDataModel? {
        return try persistence.getDataModel(id: id)
    }
    
    func getCounters() async throws -> [LocalActivityCountDataModel] {
        return try await persistence.getDataModelsAsync(getOption: .allObjects)
    }
    
    private func incrementLocalCount(localCount: Int) -> Int {
        
        let newCount: Int = localCount + 1
        
        if newCount <= 0 {
            return 1
        }
        
        return newCount
    }
    
    func incrementCounter(id: String) throws -> LocalActivityCountDataModel {
                
        let newCount: Int
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let counter: SwiftLocalActivityCount = try database.read.object(context: context, id: id) ?? SwiftLocalActivityCount()
            
            newCount = incrementLocalCount(localCount: counter.count)
            
            counter.id = id
            counter.count = newCount
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: [counter])
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let counter: RealmLocalActivityCount
            
            let existingCounter: RealmLocalActivityCount? = database.read.object(realm: realm, id: id)
            
            if let existingCounter = existingCounter {
                counter = existingCounter
            }
            else {
                counter = RealmLocalActivityCount()
                counter.id = id
            }
            
            newCount = incrementLocalCount(localCount: counter.count)

            try database.write.realm(
                realm: realm,
                writeClosure: { realm in
                    
                    counter.count = newCount
                    
                    return WriteRealmObjects(deleteObjects: nil, addObjects: [counter])
                },
                updatePolicy: .modified
            )
        }
        else {
            
            newCount = 1
        }
        
        return LocalActivityCountDataModel(
            id: id,
            count: newCount
        )
    }
    
    func decrementCount(id: String, decrementBy: Int) throws {
        
        if #available(iOS 17.4, *), let database = getSwiftPersistence()?.database {
            
            let context: ModelContext = database.openContext()
            
            let counter: SwiftLocalActivityCount? = try database.read.object(context: context, id: id)
            
            guard let counter = counter else {
                return
            }
            
            counter.count -= decrementBy
            
            if counter.count < 0 {
                counter.count = 0
            }
            
            try database.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: nil, insertObjects: [counter])
            )
        }
        else if let database = getRealmPersistence()?.database {
            
            let realm: Realm = try database.openRealm()
            
            let counter: RealmLocalActivityCount? = database.read.object(realm: realm, id: id)
            
            guard let counter = counter else {
                return
            }
            
            try database.write.realm(
                realm: realm,
                writeClosure: { realm in
                    
                    counter.count -= decrementBy
                    
                    if counter.count < 0 {
                        counter.count = 0
                    }
                    
                    return WriteRealmObjects(deleteObjects: nil, addObjects: [counter])
                },
                updatePolicy: .modified
            )
        }
    }
}
