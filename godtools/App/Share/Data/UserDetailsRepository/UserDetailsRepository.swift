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
    
    func getUserDetailsChanged() -> AnyPublisher<Void, Never> {
        
        return cache.getUserDetailsChanged()
    }
    
    func getCachedAuthUserDetails() -> UserDetailsDataModel? {
        
        return cache.getAuthUserDetails()
    }
    
    func fetchRemoteUserDetails() -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return api.fetchUserDetailsPublisher()
            .flatMap { (usersMeCodable: MobileContentApiUsersMeCodable) in
                
                let userDetails = UserDetailsDataModel(userDetailsType: usersMeCodable)
                
                return self.cache.syncUserDetails(userDetails)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAuthorizedUserDetails() -> AnyPublisher<Void, Error> {
        
        return api.deleteAuthorizedUserDetailsPublisher()
            .eraseToAnyPublisher()
    }
}
