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
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
     
        self.session = ignoreCacheSession.session
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func sendDataRequest(with urlString: String) -> AnyPublisher<Data?, Error> {
        
        return mobileContentAuthTokenRepository.getAuthTokenPublisher()
            .flatMap { authToken -> AnyPublisher<Data?, Error> in

                guard let authToken = authToken else {
                    assertionFailure("Auth token shouldn't be nil")
                    
                    return Fail(outputType: Data?.self, failure: MobileContentAuthTokenError.nilAuthToken as Error)
                        .eraseToAnyPublisher()
                }

                let urlRequest = self.buildAuthenticatedRequest(for: urlString, authToken: authToken)

                return self.attemptDataTask(with: urlRequest)
                    .mapError { urlResponseError in
                        return urlResponseError.getError()
                    }
                    .eraseToAnyPublisher()
                
            }
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
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
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
