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
        
        let fetchRequest = getUserCountersRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: fetchRequest, urlSession: ignoreCacheSession)
    }
    
    func incrementCounterPublisher(counterId: Int, incrementValue: Int) -> AnyPublisher<IncrementUserCounterResponse, URLResponseError> {
        
        let incrementRequest = getIncrementUserCountersRequest(counterId: counterId, incrementValue: incrementValue)
        
        return authSession.sendAuthenticatedRequest(urlRequest: incrementRequest, urlSession: ignoreCacheSession)
            .decode(type: IncrementUserCounterResponse.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
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
    
    private func getIncrementUserCountersRequest(counterId: Int, incrementValue: Int) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "user-counters",
                "attributes": [
                    "increment": incrementValue
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/me/counters/\(counterId)",
            method: .patch,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
}
