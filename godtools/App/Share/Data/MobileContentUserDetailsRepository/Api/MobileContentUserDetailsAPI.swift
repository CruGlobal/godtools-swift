//
//  MobileContentUserDetailsAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 11/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentUserDetailsAPI {
    
    private let authSession: MobileContentApiAuthSession
    private let ignoreCacheSession: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.ignoreCacheSession = ignoreCacheSession.session
        self.baseURL = config.mobileContentApiBaseUrl
        self.authSession = mobileContentApiAuthSession
    }
    
    private func getUserDetailsRequest(userId: String) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/" + userId,
            method: .get,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func fetchUserDetailsPublisher(userId: String) -> AnyPublisher<Data?, URLResponseError> {
        
        let urlRequest = getUserDetailsRequest(userId: userId)
        
        return authSession.sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
    }
}
