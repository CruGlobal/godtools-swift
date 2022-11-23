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
    
    func getAuthTokenPublisher(for userId: Int? = nil, oktaAccessToken: String) -> AnyPublisher<String?, URLResponseError> {
        
        if let authToken = getCachedAuthToken(for: userId) {
            
            return Just(authToken)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
            
        } else {
            
            return fetchRemoteAuthToken(oktaAccessToken: oktaAccessToken)
        }
    }
    
    func fetchRemoteAuthToken(oktaAccessToken: String) -> AnyPublisher<String?, URLResponseError> {
        
        return api.fetchAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
            .flatMap({ [weak self] authTokenDataModel -> AnyPublisher<String?, URLResponseError> in
                                
                self?.cache.storeAuthToken(authTokenDataModel)
                
                return Just(authTokenDataModel.token)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
                
            })
            .eraseToAnyPublisher()
    }
    
    private func getCachedAuthToken(for userId: Int?) -> String? {
        
        guard let userId = userId else { return nil }
        
        return cache.getAuthToken(for: userId)
    }
}
