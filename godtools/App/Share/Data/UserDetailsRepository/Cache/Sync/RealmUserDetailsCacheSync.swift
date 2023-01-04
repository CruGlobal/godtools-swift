//
//  RealmUserDetailsCacheSync.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserDetailsCacheSync {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncUserDetails(_ userDetails: UserDetailsDataModel) -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { realm in
                
                let newUserDetails: RealmUserDetails = RealmUserDetails()
                newUserDetails.mapFrom(model: userDetails)
                
                do {
                    
                    try realm.write {
                        realm.add(newUserDetails, update: .all)
                    }
                    
                    promise(.success(userDetails))
                    
                } catch let error {
                    
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
