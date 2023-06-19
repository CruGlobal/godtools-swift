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
    
    func fetchRemoteAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
        
        return api.fetchAuthTokenPublisher(providerToken: providerToken, createUser: createUser)
            .flatMap({ [weak self] authTokenDecodable -> AnyPublisher<MobileContentAuthTokenDataModel, Error> in
                
                let authTokenDataModel = MobileContentAuthTokenDataModel(decodable: authTokenDecodable)
                
                self?.cache.storeAuthToken(authTokenDataModel)
                
                return Just(authTokenDataModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
            })
            .eraseToAnyPublisher()
    }
    
    func getUserId() -> String? {
        
        return cache.getUserId()
    }
    
    func getCachedAuthTokenModel() -> MobileContentAuthTokenDataModel? {
        
        return cache.getAuthTokenData()
    }
    
    func getCachedAuthToken() -> String? {
        
        return getCachedAuthTokenModel()?.token
    }
    
    func deleteCachedAuthToken() {
        
        guard let userId = getUserId() else { return }
        
        cache.deleteAuthToken(for: userId)
    }
}
