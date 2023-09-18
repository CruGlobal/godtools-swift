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
            .eraseToAnyPublisher()
    }
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) -> AnyPublisher<Data, Error> {
        
        return getAuthToken()
            .flatMap { (authToken: String) -> AnyPublisher<Data, Error> in

                return self.attemptDataTaskWithAuthToken(authToken, urlRequest: urlRequest, session: urlSession)
                    .eraseToAnyPublisher()
                
            }
            .catch({ (error: Error) -> AnyPublisher<Data, Error> in
                
                let notAuthorized: Bool = error.code == 401
                
                if notAuthorized {
                    return self.fetchFreshAuthTokenAndReattemptDataTask(urlRequest: urlRequest, session: urlSession)
                        .eraseToAnyPublisher()
                }
                
                return Fail(error: error)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getAuthToken() -> AnyPublisher<String, Error> {
        
        if let cachedAuthTokenDataModel = mobileContentAuthTokenRepository.getCachedAuthTokenModel(), !cachedAuthTokenDataModel.isExpired {
            
            return Just(cachedAuthTokenDataModel.token).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return fetchRemoteAuthToken()
            .eraseToAnyPublisher()
    }
    
    private func fetchRemoteAuthToken(createUser: Bool = false) -> AnyPublisher<String, Error> {
                
        return userAuthentication.renewTokenPublisher()
            .flatMap { (authTokenDataModel: MobileContentAuthTokenDataModel) in
                
                return Just(authTokenDataModel.token)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTaskWithAuthToken(_ authToken: String, urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {

        let authenticatedRequest: URLRequest = buildAuthenticatedRequest(from: urlRequest, authToken: authToken)

        return session.sendUrlRequestPublisher(urlRequest: authenticatedRequest)
            .map {
                $0.data
            }
            .mapError {
                return $0.error
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
