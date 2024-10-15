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
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(baseUrl: String, ignoreCacheSession: IgnoreCacheSession) {
        
        requestSender = RequestSender(session: ignoreCacheSession.session)
        self.baseUrl = baseUrl
    }
        
    private func getGlobalAnalyticsUrlRequest() -> URLRequest {
        
        let urlRequest: URLRequest = requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/analytics/global",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
        
        return urlRequest
    }
    
    func getGlobalAnalyticsPublisher() -> AnyPublisher<MobileContentGlobalAnalyticsDecodable, Error> {
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest()
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
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
