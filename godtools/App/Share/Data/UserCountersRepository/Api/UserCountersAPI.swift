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

class UserCountersAPI: UserCountersAPIType {
    
    private let authSession: MobileContentApiAuthSession
    private let baseURL: String
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(config: AppConfig, urlSessionPriority: GetUrlSessionPriorityInterface, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.baseURL = config.getMobileContentApiBaseUrl()
        self.urlSessionPriority = urlSessionPriority
        self.authSession = mobileContentApiAuthSession
    }
    
    func fetchUserCountersPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<[UserCounterDecodable], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let fetchRequest = getUserCountersRequest(urlSession: urlSession)
        
        return authSession.sendAuthenticatedRequest(urlRequest: fetchRequest, urlSession: urlSession)
            .decode(type: JsonApiResponseDataArray<UserCounterDecodable>.self, decoder: JSONDecoder())
            .map {
                return $0.dataArray
            }
            .eraseToAnyPublisher()
    }
    
    func incrementUserCounterPublisher(id: String, increment: Int, sendRequestPriority: SendRequestPriority) -> AnyPublisher<UserCounterDecodable, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let incrementRequest = getIncrementUserCountersRequest(id: id, increment: increment, urlSession: urlSession)
        
        return authSession.sendAuthenticatedRequest(urlRequest: incrementRequest, urlSession: urlSession)
            .decode(type: JsonApiResponseDataObject<UserCounterDecodable>.self, decoder: JSONDecoder())
            .map {
                return $0.dataObject
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserCountersRequest(urlSession: URLSession) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseURL + "/users/me/counters",
                method: .get,
                headers: headers,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    private func getIncrementUserCountersRequest(id: String, increment: Int, urlSession: URLSession) -> URLRequest {
        
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
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseURL + "/users/me/counters/\(id)",
                method: .patch,
                headers: headers,
                httpBody: body,
                queryItems: nil
            )
        )
    }
}
