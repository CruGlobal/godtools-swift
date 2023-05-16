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
    
    func fetchRemoteAuthTokenPublisher(providerAccessToken: AuthenticationProviderAccessToken) -> AnyPublisher<MobileContentAuthTokenDataModel, URLResponseError> {
        
        return api.fetchAuthTokenPublisher(providerAccessToken: providerAccessToken)
            .flatMap({ [weak self] authTokenDecodable -> AnyPublisher<MobileContentAuthTokenDataModel, URLResponseError> in
                
                let authTokenDataModel = MobileContentAuthTokenDataModel(decodable: authTokenDecodable)
                
                self?.cache.storeAuthToken(authTokenDataModel)
                
                return Just(authTokenDataModel)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
                
            })
            .eraseToAnyPublisher()
    }
    
    func getUserId() -> String? {
        
        return cache.getUserId()
    }
    
    func getCachedAuthTokenModel() -> MobileContentAuthTokenDataModel? {
        
        guard
            let userId = getUserId(),
            let token = cache.getAuthToken(for: userId)
        else { return nil }
        
        return MobileContentAuthTokenDataModel(userId: userId, token: token)
    }
    
    func getCachedAuthToken() -> String? {
        
        return getCachedAuthTokenModel()?.token
    }
    
    func deleteCachedAuthToken() {
        
        guard let userId = getUserId() else { return }
        
        cache.deleteAuthToken(for: userId)
    }
}
