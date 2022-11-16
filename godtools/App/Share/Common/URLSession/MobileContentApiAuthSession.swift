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
    
    let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    let session: URLSession
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(ignoreCacheSession: IgnoreCacheSession, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
     
        self.session = ignoreCacheSession.session
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func sendDataRequest(with urlString: String) -> AnyPublisher<Data?, URLResponseError> {
        
        // TODO: - pass a user ID in the `getAuthTokenPublisher` call so that we retrieve the cached token rather than requesting a new one
        return mobileContentAuthTokenRepository.getAuthTokenPublisher()
            .flatMap { authToken -> AnyPublisher<Data?, URLResponseError> in

                return self.attemptDataTaskWithAuthToken(authToken, urlString: urlString)
                
            }
            .catch({ urlResponseError -> AnyPublisher<Data?, URLResponseError> in
                
                if urlResponseError.is401Error {
                    
                    return self.fetchFreshAuthTokenAndReattemptDataTask(urlString: urlString)
                    
                } else {
                    
                    return Fail(outputType: Data?.self, failure: urlResponseError)
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTaskWithAuthToken(_ authToken: String?, urlString: String) -> AnyPublisher<Data?, URLResponseError> {
        
        guard let authToken = authToken else {
            assertionFailure("Auth token shouldn't be nil")
            
            let error = URLResponseError.otherError(error: MobileContentAuthTokenError.nilAuthToken)
            return Fail(outputType: Data?.self, failure: error)
                .eraseToAnyPublisher()
        }

        let urlRequest = self.buildAuthenticatedRequest(for: urlString, authToken: authToken)

        return self.attemptDataTask(with: urlRequest)
            .eraseToAnyPublisher()
    }
    
    private func attemptDataTask(with urlRequest: URLRequest) -> AnyPublisher<Data?, URLResponseError> {
        
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
    
    private func fetchFreshAuthTokenAndReattemptDataTask(urlString: String) -> AnyPublisher<Data?, URLResponseError> {
        
        return mobileContentAuthTokenRepository.fetchRemoteAuthToken()
            .flatMap { authToken -> AnyPublisher<Data?, URLResponseError> in
            
                return self.attemptDataTaskWithAuthToken(authToken, urlString: urlString)
            }
            .eraseToAnyPublisher()
    }
    
    private func buildAuthenticatedRequest(for urlString: String, authToken: String) -> URLRequest {
        
        let headers: [String: String] = [
            "Authorization": authToken
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: urlString,
            method: .get,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
}
