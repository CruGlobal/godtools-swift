//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPI
    private let cache: MobileContentAuthTokenCache
        
    init(api: MobileContentAuthTokenAPI, cache: MobileContentAuthTokenCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func fetchRemoteAuthTokenPublisher(oktaAccessToken: String) -> AnyPublisher<String?, URLResponseError> {
        
        return api.fetchAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
            .flatMap({ [weak self] authTokenDataModel -> AnyPublisher<String?, URLResponseError> in
                
                self?.cache.storeAuthToken(authTokenDataModel)
                
                return Just(authTokenDataModel.token)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
                
            })
            .eraseToAnyPublisher()
    }
    
    func getUserId() -> String? {
        
        return cache.getUserId()
    }
    
    func getCachedAuthTokenModel() -> MobileContentAuthTokenRepoModel? {
        
        guard
            let userId = getUserId(),
            let token = cache.getAuthToken(for: userId)
        else { return nil }
        
        return MobileContentAuthTokenRepoModel(userId: userId, token: token)
    }
    
    func getCachedAuthToken() -> String? {
        
        return getCachedAuthTokenModel()?.token
    }
}
