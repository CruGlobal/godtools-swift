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
    
    func getGlobalAnalyticsPublisher() -> AnyPublisher<MobileContentGlobalAnalyticsDataModel, URLResponseError> {
        
        let urlRequest: URLRequest = getGlobalAnalyticsUrlRequest()
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap {
                
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject.data
            }
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
            }
            .decode(type: MobileContentGlobalAnalyticsDataModel.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
    }
}
