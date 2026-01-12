//
//  PersonalizedToolsApi.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

final class PersonalizedToolsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
            
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    private func getAllRankedResourcesUrlRequest(urlSession: URLSession) -> URLRequest {
        
        return requestBuilder
            .build(
                parameters: RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/featured",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: nil
                )
            )
    }
    
    func getAllRankedResourcesPublisher(requestPriority: RequestPriority) -> AnyPublisher<[ResourceCodable], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getAllRankedResourcesUrlRequest(urlSession: urlSession)
        
        return requestSender
            .sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable>) in
                
                let resources: [ResourceCodable] = response.successCodable?.dataArray ?? []
                return resources
            }
            .eraseToAnyPublisher()
    }
}
