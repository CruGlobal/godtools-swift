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

class MobileContentGlobalAnalyticsApi {
    
    static let sharedGlobalAnalyticsId: String = "1"
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let priorityRequestSender: PriorityRequestSenderInterface
    private let ignoreCacheSession: IgnoreCacheSession
    private let baseUrl: String
    
    init(baseUrl: String, priorityRequestSender: PriorityRequestSenderInterface, ignoreCacheSession: IgnoreCacheSession) {
        
        self.priorityRequestSender = priorityRequestSender
        self.ignoreCacheSession = ignoreCacheSession
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
    
    func getGlobalAnalyticsPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<MobileContentGlobalAnalyticsDecodable, Error> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest(urlSession: urlSession)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataObject<MobileContentGlobalAnalyticsDecodable>, NoResponseCodable>) in
                
                guard let analytics = response.successCodable?.dataObject else {
                    return MobileContentGlobalAnalyticsDecodable.createEmpty()
                }
                
                return analytics
            }
            .eraseToAnyPublisher()
    }
}
