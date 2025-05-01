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
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
            
        requestSender = RequestSender(session: ignoreCacheSession.session)
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Language
    
    private func getLanguageRequest(id: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "\(Path.languages)/\(id)",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getLanguagePublisher(id: String) -> AnyPublisher<LanguageModel?, Error> {
        
        let urlRequest: URLRequest = getLanguageRequest(id: id)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataObject<LanguageModel>, NoResponseCodable>) in
                
                return response.successCodable?.dataObject
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Languages
    
    private func getLanguagesRequest() -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + Path.languages,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getLanguages() -> AnyPublisher<[LanguageModel], Error> {
        
        let urlRequest: URLRequest = getLanguagesRequest()
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<LanguageModel>, NoResponseCodable>) in
                
                let languages: [LanguageModel] = response.successCodable?.dataArray ?? []
                return languages
            }
            .eraseToAnyPublisher()
    }
}
