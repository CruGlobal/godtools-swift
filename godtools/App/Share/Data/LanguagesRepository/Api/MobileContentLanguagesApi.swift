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
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let baseUrl: String
    
    init(config: AppConfig, urlSessionPriority: GetUrlSessionPriorityInterface) {
            
        self.urlSessionPriority = urlSessionPriority
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
    
    func getLanguages(sendRequestPriority: SendRequestPriority) -> AnyPublisher<[LanguageModel], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let urlRequest: URLRequest = getLanguagesRequest(urlSession: urlSession)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<LanguageModel>, NoResponseCodable>) in
                
                let languages: [LanguageModel] = response.successCodable?.dataArray ?? []
                return languages
            }
            .eraseToAnyPublisher()
    }
}
