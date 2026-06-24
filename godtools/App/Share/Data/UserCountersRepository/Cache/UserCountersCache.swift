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
    
    init(
        localActivityCounterCache: LocalActivityCounterCache,
        persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
    ) {

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
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>? {
        return persistence as? RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>
    }
}

extension UserCountersCache {
    
    func mergeLocalCountersWithCachedCounters() async throws -> [UserCounterDataModel] {
        
        let cachedCounters: [UserCounterDataModel] = try await persistence.getDataModels(getOption: .allObjects)
        
        return try mergeLocalCountersWithCounters(counters: cachedCounters)
    }
    
    func mergeLocalCountersWithCounters(counters: [UserCounterDataModel]) throws -> [UserCounterDataModel] {
                
        return try counters.map { (counter: UserCounterDataModel) in
            
            try mergeLocalCounterWithCounter(counter: counter)
        }
    }
    
    func getCounter(id: String) throws -> UserCounterDataModel? {
        
        let localCounter: LocalActivityCountDataModel? = try localActivityCounterCache.persistence.getDataModel(id: id)
        let counter: UserCounterDataModel? = try persistence.getDataModel(id: id)
        
        if localCounter == nil && counter == nil {
            return nil
        }
        
        let localCount: Int = localCounter?.count ?? 0
        let counterCount: Int = counter?.count ?? 0
        
        return UserCounterDataModel(id: id, count: localCount + counterCount)
    }
    
    private func mergeLocalCounterWithCounter(counter: UserCounterDataModel) throws -> UserCounterDataModel {
        
        let localCounter: LocalActivityCountDataModel? = try localActivityCounterCache.persistence.getDataModel(id: counter.id)
        
        let localCount: Int = localCounter?.count ?? 0
                    
        return UserCounterDataModel(
            id: counter.id,
            count: counter.count + localCount
        )
    }
    
    func deleteCounters() async throws {
        
        try await persistence.deleteCollection()
    }
}
