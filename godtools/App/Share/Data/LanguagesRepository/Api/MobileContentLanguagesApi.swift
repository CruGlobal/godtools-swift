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
import RepositorySync

class MobileContentLanguagesApi {
    
    private enum Path {
        static let languages = "/languages"
    }
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
            
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    private func getLanguageRequest(urlSession: URLSession, languageId: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + Path.languages + "/" + languageId,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
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
    
    private func getLanguage(requestPriority: RequestPriority, languageId: String) -> AnyPublisher<LanguageCodable?, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getLanguageRequest(urlSession: urlSession, languageId: languageId)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataObject<LanguageCodable>, NoResponseCodable>) in
                
                let language: LanguageCodable? = response.successCodable?.dataObject
                return language
            }
            .eraseToAnyPublisher()
    }
    
    private func getLanguages(requestPriority: RequestPriority) -> AnyPublisher<[LanguageCodable], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getLanguagesRequest(urlSession: urlSession)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<LanguageCodable>, NoResponseCodable>) in
                
                let languages: [LanguageCodable] = response.successCodable?.dataArray ?? []
                return languages
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - ExternalDataFetchInterface

extension MobileContentLanguagesApi: ExternalDataFetchInterface {
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[LanguageCodable], Error> {
        
        return getLanguage(requestPriority: context.requestPriority, languageId: id)
            .map { (language: LanguageCodable?) in
                
                let objects: [LanguageCodable]
                
                if let language = language {
                    objects = [language]
                } else {
                    objects = []
                }
                
                return objects
            }
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[LanguageCodable], Error> {
        
        return getLanguages(requestPriority: context.requestPriority)
            .map { (languages: [LanguageCodable]) in
                return languages
            }
            .eraseToAnyPublisher()
    }
}
