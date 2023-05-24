//
//  MobileContentApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentApi {
    
    enum Environment {
        case staging
        case production
    }
    
    static let ignoreCacheSession: URLSession = IgnoreCacheSession().session
    static let stagingUrl: String = "https://mobile-content-api-stage.cru.org"
    static let productionUrl: String = "https://mobile-content-api.cru.org"
        
    private let baseUrl: String
    
    init(environment: Environment) {
        
        switch environment {
        case .staging:
            baseUrl = MobileContentApi.stagingUrl
            
        case .production:
            baseUrl = MobileContentApi.productionUrl
        }
    }
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func sendRequest(request: MobileContentApiRequest, session: URLSession = MobileContentApi.ignoreCacheSession) -> AnyPublisher<Data, Error> {
        
        let urlRequest: URLRequest = RequestBuilder().build(
            session: session,
            urlString: baseUrl + "/" + request.path,
            method: request.method,
            headers: request.headers.value,
            httpBody: request.httpBody,
            queryItems: request.queryItems
        )
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { (tuple: (data: Data, response: URLResponse)) in
                
                let httpStatusCode: Int = (tuple.response as? HTTPURLResponse)?.statusCode ?? -1
                let isSuccessHttpStatusCode: Bool = httpStatusCode >= 200 && httpStatusCode < 400
                                
                guard isSuccessHttpStatusCode else {
                    throw NSError.errorWithDescription(description: "HTTP status code error: \(httpStatusCode)")
                }
                
                return tuple.data
            }
            .eraseToAnyPublisher()
    }
    
    func sendRequest<T: Codable>(request: MobileContentApiRequest, session: URLSession = MobileContentApi.ignoreCacheSession) -> AnyPublisher<T, Error> {
        
        return sendRequest(request: request, session: session)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                print("  WARNING: Failed to decode Codable \(String(describing: T.self)) for path \(request.path)")
                return error
            }
            .eraseToAnyPublisher()
    }
}
