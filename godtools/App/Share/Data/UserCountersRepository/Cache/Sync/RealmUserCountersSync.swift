//
//  RealmUserCountersSync.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class RealmUserCountersCacheSync {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncUserCounters(_ userCounters: [UserCounterDataModel]) -> AnyPublisher<[RealmUserCounter], Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUserCounters: [RealmUserCounter] = userCounters.map { userCounterDataModel in
                    
                    let realmUserCounter = RealmUserCounter()
                    realmUserCounter.mapFrom(model: userCounterDataModel)
                    
                    if let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounterDataModel.id) {
                        
                        realmUserCounter.incrementValue = existingCounter.incrementValue
                    }
                    
                    return realmUserCounter
                }
                
                do {
                    
                    try realm.write {
                        realm.add(newUserCounters, update: .all)
                    }
                    
                    promise(.success(newUserCounters))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    func syncUserCounter(_ userCounter: UserCounterDataModel, incrementValueBeforeSuccessfulRemoteUpdate: Int? = nil) -> AnyPublisher<RealmUserCounter, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUserCounter: RealmUserCounter = RealmUserCounter()
                newUserCounter.mapFrom(model: userCounter)
                
                if let incrementValueBeforeSuccessfulRemoteUpdate = incrementValueBeforeSuccessfulRemoteUpdate, let existingCounter = realm.object(ofType: RealmUserCounter.self, forPrimaryKey: userCounter.id) {
                    
                    // During a remote sync, it's possible the existing counter was incremented since the remote request started, so subtract initial value rather than setting to 0
                    newUserCounter.incrementValue = existingCounter.incrementValue - incrementValueBeforeSuccessfulRemoteUpdate
                }
                
                do {
                    
                    try realm.write {
                        realm.add(newUserCounter, update: .all)
                    }
                    
                    promise(.success(newUserCounter))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
