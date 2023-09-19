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
    private let session: URLSession
    private let baseUrl: String
    
    init(baseUrl: String, ignoreCacheSession: IgnoreCacheSession) {
        
        session = ignoreCacheSession.session
        self.baseUrl = baseUrl
    }
        
    private func getGlobalAnalyticsUrlRequest() -> URLRequest {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/analytics/global",
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
        
        return urlRequest
    }
    
    func getGlobalAnalyticsPublisher() -> AnyPublisher<MobileContentGlobalAnalyticsDecodable, Error> {
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest()
        
        return session.sendAndDecodeUrlRequestPublisher(urlRequest: urlRequest)
            .map { (response: JsonApiResponseData<MobileContentGlobalAnalyticsDecodable>) in
                return response.data
            }
            .eraseToAnyPublisher()
    }
}
