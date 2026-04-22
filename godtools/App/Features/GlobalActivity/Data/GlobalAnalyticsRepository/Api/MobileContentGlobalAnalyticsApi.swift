//
//  MobileContentGlobalAnalyticsApi.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

final class MobileContentGlobalAnalyticsApi {
    
    static let sharedGlobalAnalyticsId: String = "1"
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(baseUrl: String, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        self.baseUrl = baseUrl
    }
      
    private func getGlobalAnalyticsUrlRequest(urlSession: URLSession) -> URLRequest {
        
        let urlRequest: URLRequest = requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/analytics/global",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
        
        return urlRequest
    }
    
    func getGlobalAnalyticsPublisher(requestPriority: RequestPriority) -> AnyPublisher<MobileContentGlobalAnalyticsCodable, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest(urlSession: urlSession)

        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataObject<MobileContentGlobalAnalyticsCodable>, NoResponseCodable>) in
                
                guard let analytics = response.successCodable?.dataObject else {
                    return MobileContentGlobalAnalyticsCodable.createEmpty()
                }
                
                return analytics
            }
            .eraseToAnyPublisher()
    }
}
