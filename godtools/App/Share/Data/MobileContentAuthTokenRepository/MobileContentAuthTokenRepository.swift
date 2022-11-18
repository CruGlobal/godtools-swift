//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPI
    private let cache: MobileContentAuthTokenCache
    private let cruOktaAuthentication: CruOktaAuthentication
        
    init(api: MobileContentAuthTokenAPI, cache: MobileContentAuthTokenCache, cruOktaAuthentication: CruOktaAuthentication) {
        
        self.api = api
        self.cache = cache
        self.cruOktaAuthentication = cruOktaAuthentication
    }
    
    func getAuthTokenPublisher(for userId: Int? = nil, oktaAccessToken: String? = nil) -> AnyPublisher<String?, URLResponseError> {
        
        if let authToken = getCachedAuthToken(for: userId) {
            
            return Just(authToken)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
            
        } else {
            
            return fetchRemoteAuthToken(oktaAccessToken: oktaAccessToken)
        }
    }
    
    func fetchRemoteAuthToken(oktaAccessToken: String? = nil) -> AnyPublisher<String?, URLResponseError> {
        
        return getOktaAccessTokenPublisher(oktaAccessToken: oktaAccessToken)
            .flatMap ({ oktaAccessToken -> AnyPublisher<MobileContentAuthTokenDataModel, URLResponseError> in
                
                return self.api.fetchAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
            })
            .flatMap({ [weak self] authTokenDataModel -> AnyPublisher<String?, URLResponseError> in
                                
                self?.cache.storeAuthToken(authTokenDataModel)
                
                return Just(authTokenDataModel.token)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
                
            })
            .eraseToAnyPublisher()
    }
    
    private func getOktaAccessTokenPublisher(oktaAccessToken: String? = nil) -> AnyPublisher<String, URLResponseError> {
        
        if let oktaAccessToken = oktaAccessToken {
            
            return Just(oktaAccessToken)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
            
        } else {
            
            return renewOktaAccessTokenPublisher()
        }
    }
    
    private func renewOktaAccessTokenPublisher() -> AnyPublisher<String, URLResponseError> {
        
        return cruOktaAuthentication.renewAccessTokenPublisher()
            .flatMap({ (response: OktaAuthenticationResponse) -> AnyPublisher<OktaAccessToken, URLResponseError> in
                
                return response.result.publisher
                    .mapError { oktaError in
                        return URLResponseError.otherError(error: oktaError.getError())
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ oktaAccessToken in
                
                return Just(oktaAccessToken.value)
                    .setFailureType(to: URLResponseError.self)
            })
            .eraseToAnyPublisher()
    }
    
    private func getCachedAuthToken(for userId: Int?) -> String? {
        
        guard let userId = userId else { return nil }
        
        return cache.getAuthToken(for: userId)
    }
    
    private func missingOktaTokenFailure() -> AnyPublisher<String?, URLResponseError> {
        let error = URLResponseError.otherError(error: MobileContentAuthTokenError.nilOktaToken)
        return Fail(outputType: String?.self, failure: error)
            .eraseToAnyPublisher()
    }
}
