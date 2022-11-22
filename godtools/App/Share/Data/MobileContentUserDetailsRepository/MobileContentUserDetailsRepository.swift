//
//  MobileContentUserDetailsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class MobileContentUserDetailsRepository {
    
    private let api: MobileContentUserDetailsAPI
    private let cache: RealmUserCache
    
    init(api: MobileContentUserDetailsAPI, cache: RealmUserCache) {
        self.api = api
        self.cache = cache
    }
    
    func getUserChanged() -> AnyPublisher<Void, Never> {
        
        return cache.getUserChanged()
    }
    
    func getUser() -> UserDataModel? {
        
        return cache.getUser()
    }
    
    func fetchRemoteUserDetails() -> AnyPublisher<UserDataModel, URLResponseError> {
        
        return api.fetchUserDetailsPublisher()
            .flatMap { user in
                
                return self.cache.syncUser(user)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
