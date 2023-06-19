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
    
    private func getAuthTokenRequest(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> URLRequest {
        
        var attributes: [String: Any] = [
            "create_user": createUser
        ]
        
        switch providerToken {
        case .appleAuth(let authCode, let givenName, let familyName):
            
            attributes["apple_auth_code"] = authCode
            attributes["apple_given_name"] = givenName
            attributes["apple_family_name"] = familyName
            
        case .appleRefresh(let refreshToken):
            
            attributes["apple_refresh_token"] = refreshToken
                        
        case .facebook(let accessToken):
            
            attributes["facebook_access_token"] = accessToken
            
        case .google(let idToken):
            
            attributes["google_id_token"] = idToken
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
    
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, Error> {
        
        let urlRequest: URLRequest = getAuthTokenRequest(providerToken: providerToken, createUser: createUser)
        
        return session.sendAndDecodeUrlRequestPublisher(urlRequest: urlRequest)
            .map { (response: JsonApiResponseData<MobileContentAuthTokenDecodable>) in
                return response.data
            }
            .eraseToAnyPublisher()
    }
}
