//
//  UserDetailsAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 11/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class UserDetailsAPI {
    
    private let authSession: MobileContentApiAuthSession
    private let baseURL: String
    private let ignoreCacheSession: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.baseURL = config.getMobileContentApiBaseUrl()
        self.ignoreCacheSession = ignoreCacheSession.session
        self.authSession = mobileContentApiAuthSession
    }
    
    func fetchUserDetailsPublisher() -> AnyPublisher<MobileContentApiUsersMeCodable, Error> {
        
        let urlRequest: URLRequest = getAuthUserDetailsRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
            .decode(type: JsonApiResponseData<MobileContentApiUsersMeCodable>.self, decoder: JSONDecoder())
            .map {
                return $0.data
            }
            .eraseToAnyPublisher()
    }
    
    private func getAuthUserDetailsRequest() -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/me",
            method: .get,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func deleteAuthUserDetailsPublisher() -> AnyPublisher<Void, Error> {
        
        let urlRequest = getDeleteAuthorizedUserDetailsRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
            .map { (data: Data) in
                
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    private func getDeleteAuthorizedUserDetailsRequest() -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/me",
            method: .delete,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
}
