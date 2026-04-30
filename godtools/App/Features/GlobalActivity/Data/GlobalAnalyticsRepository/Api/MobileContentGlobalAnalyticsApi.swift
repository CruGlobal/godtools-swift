//
//  MobileContentGlobalAnalyticsApi.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentGlobalAnalyticsApi {
    
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
    
    func getGlobalAnalytics(requestPriority: RequestPriority) async throws -> MobileContentGlobalAnalyticsCodable? {
     
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest(urlSession: urlSession)
        
        let response = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        let codableResposne: RequestCodableResponse<JsonApiResponseDataObject<MobileContentGlobalAnalyticsCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResposne.successCodable?.dataObject
    }
}
