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
    
    private let requestSender: RequestSender
    
    let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    let userAuthentication: UserAuthentication
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(requestSender: RequestSender, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository, userAuthentication: UserAuthentication) {
     
        self.requestSender = requestSender
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
        self.userAuthentication = userAuthentication
    }
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) -> AnyPublisher<Data, Error> {
        
        return getAuthToken()
            .flatMap { (authToken: String) -> AnyPublisher<Data, Error> in

                return self.attemptDataTaskWithAuthToken(
                    authToken: authToken,
                    urlRequest: urlRequest,
                    session: urlSession
                )
                .eraseToAnyPublisher()
                
            }
            .catch({ (error: Error) -> AnyPublisher<Data, Error> in
                
                let notAuthorized: Bool = error.code == 401
                
                if notAuthorized {
                    
                    return self.fetchFreshAuthTokenAndReattemptDataTask(
                        urlRequest: urlRequest,
                        session: urlSession
                    )
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
            .mapError { (apiError: MobileContentApiError) in
                return apiError.getError()
            }
            .flatMap { (authTokenDataModel: MobileContentAuthTokenDataModel) -> AnyPublisher<String, Error> in
                
                return Just(authTokenDataModel.token).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTaskWithAuthToken(authToken: String, urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {
        
        let urlRequest: URLRequest = buildAuthenticatedRequest(from: urlRequest, authToken: authToken)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: session)
            .validate()
            .map {
                $0.data
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchFreshAuthTokenAndReattemptDataTask(urlRequest: URLRequest, session: URLSession) -> AnyPublisher<Data, Error> {
        
        return fetchRemoteAuthToken()
            .flatMap { (authToken: String) -> AnyPublisher<Data, Error> in
            
                return self.attemptDataTaskWithAuthToken(
                    authToken: authToken,
                    urlRequest: urlRequest,
                    session: session
                )
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
