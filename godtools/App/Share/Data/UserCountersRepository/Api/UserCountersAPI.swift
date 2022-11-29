//
//  UserCountersAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class UserCountersAPI {
    
    private let authSession: MobileContentApiAuthSession
    private let baseURL: String
    private let ignoreCacheSession: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.baseURL = config.mobileContentApiBaseUrl
        self.ignoreCacheSession = ignoreCacheSession.session
        self.authSession = mobileContentApiAuthSession
    }
    
    func fetchUserCountersPublisher() -> AnyPublisher<Data, URLResponseError> {
        
        let urlRequest = getUserCountersRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: urlRequest, urlSession: ignoreCacheSession)
    }
    
    private func getUserCountersRequest() -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/me/counters",
            method: .get,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
}
