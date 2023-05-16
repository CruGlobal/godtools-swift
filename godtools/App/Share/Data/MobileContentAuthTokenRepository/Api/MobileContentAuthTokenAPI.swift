//
//  MobileContentAuthTokenAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentAuthTokenAPI {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
        
        self.session = ignoreCacheSession.session
        self.baseURL = config.mobileContentApiBaseUrl
    }
    
    private func getAuthTokenRequest(providerAccessToken: AuthenticationProviderAccessToken) -> URLRequest {
        
        let attributes: [String: String]
        
        switch providerAccessToken {
        case .apple(let idToken, let givenName, let familyName):
            
            attributes = [
                "apple_id_token": idToken,
                "apple_given_name": givenName,
                "apple_family_name": familyName
            ]
            
        case .facebook(let accessToken):
            
            attributes = [
                "facebook_access_token": accessToken
            ]
            
        case .google(let idToken):
            
            attributes = [
                "google_id_token": idToken
            ]
        }
        
        let body: [String: Any] = [
            "data": [
                "type": "auth-token-request",
                "attributes": attributes
            ]
        ]
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
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
    
    func fetchAuthTokenPublisher(providerAccessToken: AuthenticationProviderAccessToken) -> AnyPublisher<MobileContentAuthTokenDecodable, URLResponseError> {
        
        return session.dataTaskPublisher(for: getAuthTokenRequest(providerAccessToken: providerAccessToken))
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
            .decode(type: JsonApiResponseData<MobileContentAuthTokenDecodable>.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .map {
                return $0.data
            }
            .eraseToAnyPublisher()
    }
}
