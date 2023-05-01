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
    
    private let mobileContentApi: MobileContentApi
    private let api: UserDetailsAPI
    private let cache: RealmUserDetailsCache
    
    init(mobileContentApi: MobileContentApi, api: UserDetailsAPI, cache: RealmUserDetailsCache) {
        
        self.mobileContentApi = mobileContentApi
        self.api = api
        self.cache = cache
    }
    
    func getUserDetailsChanged() -> AnyPublisher<Void, Never> {
        
        return cache.getUserDetailsChanged()
    }
    
    func getCachedAuthUserDetails() -> UserDetailsDataModel? {
        
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
    
    func deleteUser() -> AnyPublisher<Void, Error> {
        
    }
}
