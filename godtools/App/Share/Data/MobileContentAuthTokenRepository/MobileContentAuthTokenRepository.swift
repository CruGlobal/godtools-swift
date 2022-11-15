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

enum MobileContentAuthTokenError: Error {
    case missingOktaToken
    case nilAuthToken
}

class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPI
    private let cache: MobileContentAuthTokenCache
    private let cruOktaAuthentication: CruOktaAuthentication
        
    init(api: MobileContentAuthTokenAPI, cache: MobileContentAuthTokenCache, cruOktaAuthentication: CruOktaAuthentication) {
        
        self.api = api
        self.cache = cache
        self.cruOktaAuthentication = cruOktaAuthentication
    }
    
    func getAuthTokenPublisher(for userId: Int? = nil, oktaAccessToken: String? = nil) -> AnyPublisher<String?, Error> {
        
        if let authToken = getCachedAuthToken(for: userId) {
            
            return Just(authToken)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
        } else if let oktaAccessToken = oktaAccessToken ?? cruOktaAuthentication.getAccessTokenFromPersistentStore() {
            // TODO: -  `getAccessTokenFromPersistentStore` should be updated to `withFreshTokenPerformAction` based on https://github.com/okta/okta-oidc-ios/blob/e5450a3aab5c194a7470addeef176e769a374650/Sources/AppAuth/OKTAuthState.m#L90-L93
            
            return fetchRemoteAuthToken(oktaAccessToken: oktaAccessToken)
                .mapError { urlResponseError in
                    return urlResponseError.getError()
                }
                .eraseToAnyPublisher()
            
        } else {
            
            return Fail(outputType: String?.self, failure: MobileContentAuthTokenError.missingOktaToken)
                .eraseToAnyPublisher()
                
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
