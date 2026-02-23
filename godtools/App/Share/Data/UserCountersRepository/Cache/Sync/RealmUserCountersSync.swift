//
//  RealmUserCountersSync.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

class RealmUserCountersCacheSync {
    
    private let realmDatabase: LegacyRealmDatabase
    
    init(realmDatabase: LegacyRealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func incrementUserCounterBy1(id: String) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let newUserCounter: RealmUserCounter = RealmUserCounter()
            newUserCounter.id = id
            
            if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: id) {
                
                newUserCounter.latestCountFromAPI = existingCounter.latestCountFromAPI
                newUserCounter.incrementValue = existingCounter.incrementValue + 1
                
            } else {
                
                newUserCounter.incrementValue = 1
            }
            
            return [newUserCounter]
            
        } mapInBackgroundClosure: { (objects: [RealmUserCounter]) in
            
            objects.map {
                UserCounterDataModel(realmUserCounter: $0)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func syncUserCounter(_ userCounter: UserCounterDecodable, incrementValueBeforeRemoteUpdate: Int) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let newUserCounter: RealmUserCounter = RealmUserCounter()
            newUserCounter.mapFrom(model: userCounter)
            
            if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounter.id) {
                
                // During a remote sync, it's possible the existing counter was incremented since the remote request started, so subtract initial value rather than setting to 0
                newUserCounter.incrementValue = existingCounter.incrementValue - incrementValueBeforeRemoteUpdate
            }
            
            return [newUserCounter]
            
        } mapInBackgroundClosure: { (objects: [RealmUserCounter]) in
            
            objects.map {
                UserCounterDataModel(realmUserCounter: $0)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func syncUserCounters(_ userCounters: [UserCounterDecodable]) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) in
            
            let newUserCounters: [RealmUserCounter] = userCounters.map { userCounterDataModel in
                
                let realmUserCounter = RealmUserCounter()
                realmUserCounter.mapFrom(model: userCounterDataModel)
                
                if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounterDataModel.id) {
                    
                    realmUserCounter.incrementValue = existingCounter.incrementValue
                }
                
                return realmUserCounter
            }
            
            return newUserCounters
            
        } mapInBackgroundClosure: { (objects: [RealmUserCounter]) in
            
            objects.map {
                UserCounterDataModel(realmUserCounter: $0)
            }
        }
        .eraseToAnyPublisher()
    }
}
