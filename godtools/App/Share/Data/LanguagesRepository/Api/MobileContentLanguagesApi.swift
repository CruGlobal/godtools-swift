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
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
            
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
    
    func getLanguages() -> AnyPublisher<[LanguageModel], Error> {
        
        let urlRequest: URLRequest = getLanguagesRequest()
        
        return session.sendAndDecodeUrlRequestPublisher(urlRequest: urlRequest)
            .map { (languagesResponse: JsonApiResponseData<[LanguageModel]>) in
                return languagesResponse.data
            }
            .eraseToAnyPublisher()
    }
}
