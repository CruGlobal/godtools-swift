//
//  RealmUserDetailsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserDetailsCache {
    
    private let realmDatabase: RealmDatabase
    private let authTokenRepository: MobileContentAuthTokenRepository
    
    init(realmDatabase: RealmDatabase, authTokenRepository: MobileContentAuthTokenRepository) {
        
        self.realmDatabase = realmDatabase
        self.authTokenRepository = authTokenRepository
    }
    
    func getAuthUserDetailsChangedPublisher() -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserDetails.self).objectWillChange
            .map { _ in
                return self.getAuthUserDetails()
            }
            .eraseToAnyPublisher()
    }
    
    func getUserDetailsChangedPublisher(id: String) -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserDetails.self).objectWillChange
            .map { _ in
                
                let realmObject: RealmUserDetails? = self.realmDatabase.readObject(primaryKey: id)
                
                if let realmObject = realmObject {
                    return UserDetailsDataModel(userDetailsType: realmObject)
                }
                
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    func getAuthUserDetails() -> UserDetailsDataModel? {
        
        guard let userId = authTokenRepository.getUserId() else {
            return nil
        }
        
        guard let realmUserDetails = realmDatabase.openRealm().object(ofType: RealmUserDetails.self, forPrimaryKey: userId) else {
            return nil
        }
        
        return UserDetailsDataModel(userDetailsType: realmUserDetails)
    }
    
    func storeUserDetailsPublisher(userDetails: UserDetailsDataModel) -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmUserDetails] in
            
            let newUserDetails: RealmUserDetails = RealmUserDetails()
            newUserDetails.mapFrom(model: userDetails)
            
            return [newUserDetails]
            
        } mapInBackgroundClosure: { (objects: [RealmUserDetails]) in
            return objects
        }
        .map { _ in
            return userDetails
        }
        .eraseToAnyPublisher()
    }
}
