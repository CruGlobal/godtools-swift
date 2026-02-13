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
import RepositorySync

class UserCountersAPI: UserCountersApiInterface {
    
    private let authSession: MobileContentApiAuthSession
    private let baseURL: String
    private let urlSessionPriority: URLSessionPriority
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.baseURL = config.getMobileContentApiBaseUrl()
        self.urlSessionPriority = urlSessionPriority
        self.authSession = mobileContentApiAuthSession
    }
    
    func fetchUserCounters(requestPriority: RequestPriority) async throws -> [UserCounterDecodable] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let fetchRequest = getUserCountersRequest(urlSession: urlSession)
        
        let data: Data = try await authSession.sendAuthenticatedRequest(
            urlRequest: fetchRequest,
            urlSession: urlSession
        )
        
        let codable: JsonApiResponseDataArray<UserCounterDecodable> = try JSONDecoder().decode(
            JsonApiResponseDataArray<UserCounterDecodable>.self,
            from: data
        )
        
        return codable.dataArray
    }
    
    func incrementUserCounter(id: String, increment: Int, requestPriority: RequestPriority) async throws -> UserCounterDecodable {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let incrementRequest = getIncrementUserCountersRequest(id: id, increment: increment, urlSession: urlSession)
        
        let data: Data = try await authSession.sendAuthenticatedRequest(
            urlRequest: incrementRequest,
            urlSession: urlSession
        )
        
        let codable: JsonApiResponseDataObject<UserCounterDecodable> = try JSONDecoder().decode(
            JsonApiResponseDataObject<UserCounterDecodable>.self,
            from: data
        )
        
        return codable.dataObject
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

extension UserCountersAPI: ExternalDataFetchInterface {

    func getObject(id: String, context: RequestOperationFetchContext) async throws -> [UserCounterDecodable] {
        
        return try await emptyResponse()
    }
    
    func getObjects(context: RequestOperationFetchContext) async throws -> [UserCounterDecodable] {
        
        return try await emptyResponse()
    }
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[UserCounterDecodable], Error> {
        
        return emptyResponsePublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[UserCounterDecodable], Error> {
        
        return emptyResponsePublisher()
    }
}
