//
//  RealmUserCacheSync.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

struct RealmUserCacheSync {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncUser(user: UserDataModel) -> AnyPublisher<UserDataModel, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUser: RealmUser = RealmUser()
                newUser.mapFrom(model: user)
                
                do {
                    
                    try realm.write {
                        realm.add(newUser, update: .all)
                    }
                    
                    promise(.success(user))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
