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
        
        self.baseURL = config.mobileContentApiBaseUrl
        self.ignoreCacheSession = ignoreCacheSession.session
        self.authSession = mobileContentApiAuthSession
    }
    
    private func getUserDetailsRequest() -> URLRequest {
        
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
    
    func fetchUserDetailsPublisher() -> AnyPublisher<UserDetailsDataModel, URLResponseError> {
        
        let urlRequest = getUserDetailsRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
            .decode(type: UserDetailsDataModel.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
    }
}
