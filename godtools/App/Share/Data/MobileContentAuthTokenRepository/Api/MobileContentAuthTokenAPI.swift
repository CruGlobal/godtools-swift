//
//  MobileContentAuthTokenAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import OktaAuthentication
import Combine

class MobileContentAuthTokenAPI {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
        
        self.session = ignoreCacheSession.session
        self.baseURL = config.mobileContentApiBaseUrl
    }
    
    private func getAuthTokenRequest(oktaAccessToken: OktaAccessToken) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "auth-token-request",
                "attributes": [
                    "okta_access_token": oktaAccessToken.value
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: baseURL + "/auth",
            method: .post,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
    
    func getAuthToken(oktaAccessToken: OktaAccessToken) -> AnyPublisher<[String: [String: String]], URLResponseError> {
        
        return session.dataTaskPublisher(for: getAuthTokenRequest(oktaAccessToken: oktaAccessToken))
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
            // TODO: - decode this correctly
            .decode(type: [String: [String: String]].self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
    }
}
