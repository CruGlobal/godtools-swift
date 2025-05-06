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
    
    private let ignoreCacheSession: IgnoreCacheSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let priorityRequestSender: PriorityRequestSenderInterface
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession, priorityRequestSender: PriorityRequestSenderInterface) {
            
        self.ignoreCacheSession = ignoreCacheSession
        self.priorityRequestSender = priorityRequestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    private func getLanguagesRequest(urlSession: URLSession) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + Path.languages,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getLanguages() -> AnyPublisher<[LanguageModel], Error> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let urlRequest: URLRequest = getLanguagesRequest(urlSession: urlSession)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: .medium)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<LanguageModel>, NoResponseCodable>) in
                
                let languages: [LanguageModel] = response.successCodable?.dataArray ?? []
                return languages
            }
            .eraseToAnyPublisher()
    }
}
