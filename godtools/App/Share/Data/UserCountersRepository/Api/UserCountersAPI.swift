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
    
    func fetchUserCountersPublisher() -> AnyPublisher<[UserCounterDecodable], URLResponseError> {
        
        let fetchRequest = getUserCountersRequest()
        
        return authSession.sendAuthenticatedRequest(urlRequest: fetchRequest, urlSession: ignoreCacheSession)
            .decode(type: GetUserCountersResponseDecodable.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .flatMap { getUserCountersResponse in
                
                return Just(getUserCountersResponse.userCounters)
            }
            .eraseToAnyPublisher()
    }
    
    func incrementCounterPublisher(id: String, increment: Int) -> AnyPublisher<UserCounterDecodable, URLResponseError> {
        
        let incrementRequest = getIncrementUserCountersRequest(id: id, increment: increment)
        
        return authSession.sendAuthenticatedRequest(urlRequest: incrementRequest, urlSession: ignoreCacheSession)
            .decode(type: IncrementUserCounterResponseDecodable.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .flatMap { incrementUserCounterResponse in
                
                return Just(incrementUserCounterResponse.userCounter)
                    .setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
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
    
    private func getIncrementUserCountersRequest(id: String, increment: Int) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "user-counters",
                "attributes": [
                    "increment": increment
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: ignoreCacheSession,
            urlString: baseURL + "/users/me/counters/\(id)",
            method: .patch,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
}
