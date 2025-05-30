//
//  MobileContentResourceViewsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentResourceViewsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let baseUrl: String
    
    init(config: AppConfig, urlSessionPriority: GetUrlSessionPriorityInterface) {
                    
        self.urlSessionPriority = urlSessionPriority
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    private func getResourceViewRequest(resourceView: ResourceViewModelType, urlSession: URLSession) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "view",
                "attributes": [
                    "resource_id": resourceView.resourceId,
                    "quantity": resourceView.quantity
                ]
            ]
        ]
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/views",
                method: .post,
                headers: headers,
                httpBody: body,
                queryItems: nil
            )
        )
    }
    
    func postResourceViewPublisher(resourceView: ResourceViewModelType, sendRequestPriority: SendRequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let urlRequest = getResourceViewRequest(resourceView: resourceView, urlSession: urlSession)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .eraseToAnyPublisher()
    }
}
