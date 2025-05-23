//
//  UserDetailsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class UserDetailsRepository {
    
    private let api: UserDetailsAPI
    private let cache: RealmUserDetailsCache
    
    init(api: UserDetailsAPI, cache: RealmUserDetailsCache) {
        self.api = api
        self.cache = cache
    }
    
    func getAuthUserDetailsChangedPublisher() -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return cache.getAuthUserDetailsChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func getUserDetailsChangedPublisher(id: String) -> AnyPublisher<UserDetailsDataModel?, Never> {
        
        return cache.getUserDetailsChangedPublisher(id: id)
            .eraseToAnyPublisher()
    }
    
    func getCachedAuthUserDetails() -> UserDetailsDataModel? {
        
        return cache.getAuthUserDetails()
    }
    
    func getAuthUserDetailsFromRemotePublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return api.fetchUserDetailsPublisher(sendRequestPriority: sendRequestPriority)
            .flatMap { (usersMeCodable: MobileContentApiUsersMeCodable) in
                
                let userDetails = UserDetailsDataModel(userDetailsType: usersMeCodable)
                
                return self.cache.storeUserDetailsPublisher(userDetails: userDetails)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAuthUserDetailsPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<Void, Error> {
        
        return api.deleteAuthUserDetailsPublisher(sendRequestPriority: sendRequestPriority)
            .eraseToAnyPublisher()
    }
}
