//
//  MobileContentResourceViewsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentResourceViewsApi: ResourceViewsApiInterface {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSenderInterface
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSenderInterface) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    private func getResourceViewRequest(resourceId: String, quantity: Int, urlSession: URLSession) throws -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "view",
                "attributes": [
                    "resource_id": resourceId,
                    "quantity": quantity
                ]
            ]
        ]
        
        return try requestBuilder.build(
            parameters: try RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/views",
                method: .post,
                headers: headers,
                httpBody: body,
                queryItems: nil
            )
        )
    }
    
    func postResourceView(resourceId: String, quantity: Int, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = try getResourceViewRequest(
            resourceId: resourceId,
            quantity: quantity,
            urlSession: urlSession
        )
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
