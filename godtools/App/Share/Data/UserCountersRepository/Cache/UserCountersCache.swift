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
    
    private let localActivityCounterCache: LocalActivityCounterCache
    
    let persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
    
    init(localActivityCounterCache: LocalActivityCounterCache, persistence: any Persistence<UserCounterDataModel, UserCounterCodable>) {

        self.localActivityCounterCache = localActivityCounterCache
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, SwiftUserCounter>? {
        return persistence as? SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, SwiftUserCounter>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>? {
        return persistence as? RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>
    }
}

extension UserCountersCache {
    
    func mergeLocalCountersWithCachedCounters() async throws -> [UserCounterDataModel] {
        
        let cachedCounters: [UserCounterDataModel] = try await persistence.getDataModelsAsync(getOption: .allObjects)
        
        return try mergeLocalCountersWithCounters(counters: cachedCounters)
    }
    
    func mergeLocalCountersWithCounters(counters: [UserCounterDataModel]) throws -> [UserCounterDataModel] {
                
        return try counters.map { (counter: UserCounterDataModel) in
            
            try mergeLocalCounterWithCounter(counter: counter)
        }
    }
    
    func getCounter(id: String) throws -> UserCounterDataModel? {
        
        guard let counter = try persistence.getDataModel(id: id) else {
            return nil
        }
        
        return try mergeLocalCounterWithCounter(counter: counter)
    }
    
    private func mergeLocalCounterWithCounter(counter: UserCounterDataModel) throws -> UserCounterDataModel {
        
        let localCounter: LocalActivityCountDataModel? = try localActivityCounterCache.persistence.getDataModel(id: counter.id)
        
        let localCount: Int = localCounter?.count ?? 0
                    
        return UserCounterDataModel(
            id: counter.id,
            count: counter.count + localCount
        )
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
