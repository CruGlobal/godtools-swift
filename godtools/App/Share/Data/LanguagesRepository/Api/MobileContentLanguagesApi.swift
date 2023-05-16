//
//  MobileContentLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentLanguagesApi {
    
    private enum Path {
        static let languages = "/languages"
    }
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
            
        session = ignoreCacheSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func getLanguagesRequest() -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + Path.languages,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func getLanguages() -> AnyPublisher<[LanguageModel], URLResponseError> {
        
        return session.dataTaskPublisher(for: getLanguagesRequest())
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
            .decode(type: JsonApiResponseData<[LanguageModel]>.self, decoder: JSONDecoder())
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .map {
                return $0.data
            }
            .eraseToAnyPublisher()
    }
}
