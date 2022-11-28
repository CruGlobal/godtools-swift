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
    
    func sendGetRequestIgnoringCache(with urlString: String) -> AnyPublisher<Data, URLResponseError> {
        
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
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) -> AnyPublisher<Data, URLResponseError> {
        
        return getAuthToken()
            .flatMap { authToken -> AnyPublisher<Data, URLResponseError> in

                return self.attemptDataTaskWithAuthToken(authToken, urlRequest: urlRequest, session: urlSession)
                
            }
            .catch({ urlResponseError -> AnyPublisher<Data, URLResponseError> in
                
                if urlResponseError.is401Error {
                    
                    return self.fetchFreshAuthTokenAndReattemptDataTask(urlRequest: urlRequest, session: urlSession)
                    
                } else {
                    
                    return Fail(outputType: Data.self, failure: urlResponseError)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func getAuthToken() -> AnyPublisher<String?, URLResponseError> {
        
        if let cachedAuthToken = mobileContentAuthTokenRepository.getCachedAuthToken() {
            
            return Just(cachedAuthToken)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
            
        } else {
            
            return fetchRemoteAuthToken()
        }
    }
    
    private func fetchRemoteAuthToken() -> AnyPublisher<String?, URLResponseError> {
        
        return userAuthentication.renewOktaAccessTokenPublisher()
            .flatMap { oktaAccessToken in
                
                return self.mobileContentAuthTokenRepository.fetchRemoteAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
                   .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTaskWithAuthToken(_ authToken: String?, urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, URLResponseError> {
        
        guard let authToken = authToken else {
            assertionFailure("Auth token shouldn't be nil")
            
            let error = URLResponseError.otherError(error: MobileContentAuthTokenError.nilAuthToken)
            return Fail(outputType: Data.self, failure: error)
                .eraseToAnyPublisher()
        }

        let authenticatedRequest = buildAuthenticatedRequest(from: urlRequest, authToken: authToken)

        return attemptDataTask(with: authenticatedRequest, session: session)
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTask(with urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, URLResponseError> {
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap {
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject.data
            }
            .mapError { error in
                if let urlResponseError = error as? URLResponseError {
                    return urlResponseError
               
                } else {
                    return URLResponseError.requestError(error: error as Error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchFreshAuthTokenAndReattemptDataTask(urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, URLResponseError> {
        
        return fetchRemoteAuthToken()
            .flatMap { authToken -> AnyPublisher<Data, URLResponseError> in
            
                return self.attemptDataTaskWithAuthToken(authToken, urlRequest: urlRequest, session: session)
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
