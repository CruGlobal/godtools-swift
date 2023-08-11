//
//  RealmUserCountersCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserCountersCache {
    
    private let realmDatabase: RealmDatabase
    private let userCountersSync: RealmUserCountersCacheSync
    
    init(realmDatabase: RealmDatabase, userCountersSync: RealmUserCountersCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.userCountersSync = userCountersSync
    }
    
    func getUserCountersChanged() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserCounter.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUserCounter(id: String) -> UserCounterDataModel? {
        
        guard let realmUserCounter = realmDatabase.openRealm().object(ofType: RealmUserCounter.self, forPrimaryKey: id) else {
            return nil
        }
        
        return UserCounterDataModel(realmUserCounter: realmUserCounter)
    }
    
    func getAllUserCounters() -> [UserCounterDataModel] {
        
        return realmDatabase.openRealm().objects(RealmUserCounter.self)
            .map { UserCounterDataModel(realmUserCounter: $0) }
    }
    
    func getUserCountersWithIncrementGreaterThanZero() -> [UserCounterDataModel] {
        
        return realmDatabase.openRealm().objects(RealmUserCounter.self)
            .filter(NSPredicate(format: "%K > 0", #keyPath(RealmUserCounter.incrementValue)))
            .map { UserCounterDataModel(realmUserCounter: $0) }
    }
    
    func incrementUserCounterBy1(id: String) -> AnyPublisher<UserCounterDataModel, Error> {
        
        return userCountersSync.incrementUserCounterBy1(id: id)
    }
    
    func syncUserCounter(_ userCounter: UserCounterDecodable, incrementValueBeforeRemoteUpdate: Int) -> AnyPublisher<UserCounterDataModel, Error> {
        
        return userCountersSync.syncUserCounter(userCounter, incrementValueBeforeRemoteUpdate: incrementValueBeforeRemoteUpdate)
    }
    
    func syncUserCounters(_ userCounters: [UserCounterDecodable]) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return userCountersSync.syncUserCounters(userCounters)
    }
}
