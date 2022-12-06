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
    
    func getAuthUserDetails() -> UserDetailsDataModel? {
        
        return cache.getAuthUserDetails()
    }
    
    func fetchRemoteUserDetails() -> AnyPublisher<UserDetailsDataModel, URLResponseError> {
        
        return api.fetchUserDetailsPublisher()
            .flatMap { userDetails in
                
                return self.cache.syncUserDetails(userDetails)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
