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
        
        guard let realmUserCounter = realmDatabase.openRealm().object(ofType: RealmUserCounter.self, forPrimaryKey: id) else { return nil }
        
        return UserCounterDataModel(realmUserCounter: realmUserCounter)
    }
    
    func syncUserCounter(_ userCounter: UserCounterDecodable, incrementValueBeforeSuccessfulRemoteUpdate: Int? = nil) -> AnyPublisher<UserCounterDataModel, Error> {
        
        return userCountersSync.syncUserCounter(userCounter, incrementValueBeforeSuccessfulRemoteUpdate: incrementValueBeforeSuccessfulRemoteUpdate)
            .flatMap { realmUserCounter in
                
                return Just(UserCounterDataModel(realmUserCounter: realmUserCounter))
            }
            .eraseToAnyPublisher()
    }
    
    func syncUserCounters(_ userCounters: [UserCounterDecodable]) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return userCountersSync.syncUserCounters(userCounters)
            .flatMap { realmUserCounters in
                
                let userCounterDataModels = realmUserCounters.map{ UserCounterDataModel(realmUserCounter: $0) }
                
                return Just(userCounterDataModels)
            }
            .eraseToAnyPublisher()
    }
}
