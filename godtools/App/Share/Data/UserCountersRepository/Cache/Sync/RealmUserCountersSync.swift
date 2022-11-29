//
//  RealmUserCountersSync.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

struct RealmUserCountersCacheSync {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncUserCounters(_ userCounters: [UserCounterDataModel]) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUserCounters: [RealmUserCounter] = userCounters.map { userCounterDataModel in
                    
                    let realmUserCounter = RealmUserCounter()
                    realmUserCounter.mapFrom(model: userCounterDataModel)
                    
                    return realmUserCounter
                }
                
                do {
                    
                    try realm.write {
                        realm.add(newUserCounters, update: .all)
                    }
                    
                    promise(.success(userCounters))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    func syncUserCounter(_ userCounter: UserCounterDataModel) -> AnyPublisher<UserCounterDataModel, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUserCounter: RealmUserCounter = RealmUserCounter()
                newUserCounter.mapFrom(model: userCounter)
                
                do {
                    
                    try realm.write {
                        realm.add(newUserCounter, update: .all)
                    }
                    
                    promise(.success(userCounter))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
