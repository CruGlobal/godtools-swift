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
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let baseUrl: String
    
    init(baseUrl: String, urlSessionPriority: GetUrlSessionPriorityInterface) {
        
        self.urlSessionPriority = urlSessionPriority
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
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest(urlSession: urlSession)

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
