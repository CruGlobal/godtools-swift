//
//  MobileContentApiAuthSession.swift
//  godtools
//
//  Created by Rachael Skeath on 11/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentApiAuthSession {
    
    let ignoreCacheSession: URLSession
    let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    let userAuthentication: UserAuthentication
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(ignoreCacheSession: IgnoreCacheSession, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository, userAuthentication: UserAuthentication) {
     
        self.ignoreCacheSession = ignoreCacheSession.session
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
        self.userAuthentication = userAuthentication
    }
    
    func sendGetRequestIgnoringCache(with urlString: String) -> AnyPublisher<Data, Error> {
        
        let urlRequest = requestBuilder.build(
            session: ignoreCacheSession,
            urlString: urlString,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
        
        return sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
    }
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) -> AnyPublisher<Data, Error> {
        
        return getAuthToken()
            .flatMap { (authToken: String) -> AnyPublisher<Data, Error> in

                return self.attemptDataTaskWithAuthToken(authToken, urlRequest: urlRequest, session: urlSession)
                
            }
            .catch({ (error: Error) -> AnyPublisher<Data, Error> in
                
                // TODO: Update RequestOperation to include is401Error ? ~Levi
                if error.code == 401 {
                    
                    return self.fetchFreshAuthTokenAndReattemptDataTask(urlRequest: urlRequest, session: urlSession)
                    
                } else {
                    
                    return Fail(outputType: Data.self, failure: error)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func getAuthToken() -> AnyPublisher<String, Error> {
        
        if let cachedAuthToken = mobileContentAuthTokenRepository.getCachedAuthToken() {
            
            return Just(cachedAuthToken)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
        } else {
            
            return fetchRemoteAuthToken()
        }
    }
    
    private func fetchRemoteAuthToken(createUser: Bool = false) -> AnyPublisher<String, Error> {
                
        return userAuthentication.renewTokenPublisher()
            .flatMap { (authProviderResponse: AuthenticationProviderResponse) in
                       
                return authProviderResponse.getMobileContentAuthProviderToken().publisher
                    .eraseToAnyPublisher()
            }
            .flatMap { providerToken in
                
                return self.mobileContentAuthTokenRepository.fetchRemoteAuthTokenPublisher(providerToken: providerToken, createUser: createUser)
                   .eraseToAnyPublisher()
            }
            .flatMap { authTokenDataModel in
                
                return Just(authTokenDataModel.token)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTaskWithAuthToken(_ authToken: String, urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {

        let authenticatedRequest = buildAuthenticatedRequest(from: urlRequest, authToken: authToken)

        return attemptDataTask(with: authenticatedRequest, session: session)
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTask(with urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {
        
        return session.sendUrlRequestPublisher(urlRequest: urlRequest)
            .map {
                return $0.data
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchFreshAuthTokenAndReattemptDataTask(urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {
        
        return fetchRemoteAuthToken()
            .flatMap { (authToken: String) -> AnyPublisher<Data, Error> in
            
                return self.attemptDataTaskWithAuthToken(authToken, urlRequest: urlRequest, session: session)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func buildAuthenticatedRequest(from urlRequest: URLRequest, authToken: String) -> URLRequest {
        
        var authenticatedRequest = urlRequest
        
        var headers = [String: String]()
        if let existingHeaders = authenticatedRequest.allHTTPHeaderFields {
            
            headers = existingHeaders
        }
        
        headers["Authorization"] = authToken
        authenticatedRequest.allHTTPHeaderFields = headers
        
        return authenticatedRequest
    }
}
