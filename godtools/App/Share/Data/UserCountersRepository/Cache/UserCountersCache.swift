//
//  UserCountersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import RepositorySync

class UserCountersCache {
    
    private let persistence: any Persistence<UserCounterDataModel, UserCounterDecodable>
    
    init(persistence: any Persistence<UserCounterDataModel, UserCounterDecodable>) {
        
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterDecodable, SwiftUserCounter>? {
        return persistence as? SwiftRepositorySyncPersistence<UserCounterDataModel, UserCounterDecodable, SwiftUserCounter>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterDecodable, RealmUserCounter>? {
        return persistence as? RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterDecodable, RealmUserCounter>
    }
}

// MARK - Cache

extension UserCountersCache {
    
    private var greaterThanZeroNSPredicate: NSPredicate {
        return NSPredicate(format: "%K > 0", #keyPath(RealmUserCounter.incrementValue))
    }
    
    func getUserCounter(id: String) throws -> UserCounterDataModel? {
        
        let userCounter: UserCounterDataModel? = try persistence.getDataModel(id: id)
        
        return userCounter
    }
    
    func getAllUserCounters() async throws -> [UserCounterDataModel] {
        
        return try await persistence.getDataModelsAsync(getOption: .allObjects)
    }
    
    func getUserCountersWithIncrementGreaterThanZero() async throws -> [UserCounterDataModel] {
        
        if let realmPersistence = getRealmPersistence() {
            
            return try await realmPersistence.getDataModelsAsync(
                getOption: .allObjects,
                query: RealmDatabaseQuery.filter(filter: greaterThanZeroNSPredicate)
            )
        }
        else {
            
            return Array()
        }
    }
    
    func deleteAllUserCounters() throws {
        
        if let realmDatabase = realmDatabase {
            
            let realm: Realm = try realmDatabase.openRealm()
            
            let userCounters: [RealmUserCounter] = realmDatabase.read.objects(
                realm: realm,
                query: nil
            )
            
            try realmDatabase.write.realm(
                realm: realm,
                writeClosure: { (realm: Realm) in
                    return WriteRealmObjects(
                        deleteObjects: userCounters,
                        addObjects: nil
                    )
                },
                updatePolicy: .modified
            )
        }
    }
}

// MARK: - Sync

extension UserCountersCache {
    
    func incrementUserCounterBy1(id: String) throws -> [UserCounterDataModel] {
        
        if let realmDatabase = realmDatabase {
            
            let realm = try realmDatabase.openRealm()
            
            let newUserCounter: RealmUserCounter = RealmUserCounter()
            newUserCounter.id = id
            
            let existingCounter: RealmUserCounter? = realmDatabase.read.object(realm: realm, id: id)
            
            if let existingCounter = existingCounter {
                
                newUserCounter.latestCountFromAPI = existingCounter.latestCountFromAPI
                newUserCounter.incrementValue = existingCounter.incrementValue + 1
                
            } else {
                
                newUserCounter.incrementValue = 1
            }
            
            let newUserCounters: [RealmUserCounter] = [newUserCounter]
            
            try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
                return WriteRealmObjects(deleteObjects: nil, addObjects: newUserCounters)
            }, updatePolicy: .all)
            
            return newUserCounters.map { (realmUserCounter: RealmUserCounter) in
                UserCounterDataModel(interface: realmUserCounter)
            }
        }
        else {
            
            return Array()
        }
    }
    
    func syncUserCounter(userCounter: UserCounterDecodable, incrementValueBeforeRemoteUpdate: Int) throws -> [UserCounterDataModel] {
        
        if let realmDatabase = realmDatabase {
            
            let realm = try realmDatabase.openRealm()
            
            let newUserCounter: RealmUserCounter = RealmUserCounter()
            newUserCounter.mapFrom(interface: userCounter)
            
            if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounter.id) {
                
                // During a remote sync, it's possible the existing counter was incremented since the remote request started, so subtract initial value rather than setting to 0
                newUserCounter.incrementValue = existingCounter.incrementValue - incrementValueBeforeRemoteUpdate
            }
            
            let newUserCounters: [RealmUserCounter] =  [newUserCounter]
            
            try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
                return WriteRealmObjects(deleteObjects: nil, addObjects: newUserCounters)
            }, updatePolicy: .all)
            
            return newUserCounters.map { (realmUserCounter: RealmUserCounter) in
                UserCounterDataModel(interface: realmUserCounter)
            }
        }
        else {
            
            return Array()
        }
    }
    
    func syncUserCounters(userCounters: [UserCounterDecodable]) throws -> [UserCounterDataModel] {
        
        if let realmDatabase = realmDatabase {
            
            let realm = try realmDatabase.openRealm()
            
            let newUserCounters: [RealmUserCounter] = userCounters.map { userCounterDataModel in
                
                let realmUserCounter = RealmUserCounter()
                realmUserCounter.mapFrom(interface: userCounterDataModel)
                
                if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounterDataModel.id) {
                    
                    realmUserCounter.incrementValue = existingCounter.incrementValue
                }
                
                return realmUserCounter
            }
            
            try realmDatabase.write.realm(realm: realm, writeClosure: { realm in
                return WriteRealmObjects(deleteObjects: nil, addObjects: newUserCounters)
            }, updatePolicy: .all)
            
            return newUserCounters.map { (realmUserCounter: RealmUserCounter) in
                UserCounterDataModel(interface: realmUserCounter)
            }
        }
        else {
            
            return Array()
        }
    }
}
