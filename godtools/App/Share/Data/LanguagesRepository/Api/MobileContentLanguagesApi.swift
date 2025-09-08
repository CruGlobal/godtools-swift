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
    
    @available(*, deprecated) // TODO: GT-1887 Make private. ~Levi
    func getLanguages(requestPriority: RequestPriority) -> AnyPublisher<[LanguageCodable], Error> {
        
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

// MARK: - RepositorySyncExternalDataFetchInterface

extension MobileContentLanguagesApi: RepositorySyncExternalDataFetchInterface {
    
    func getObjectPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<LanguageCodable>, Never> {
        
        return getLanguage(requestPriority: requestPriority, languageId: id)
            .map { (language: LanguageCodable?) in
                
                let objects: [LanguageCodable]
                
                if let language = language {
                    objects = [language]
                } else {
                    objects = []
                }
                
                return RepositorySyncResponse(objects: objects, errors: [])
            }
            .catch { (error: Error) in
                return Just(RepositorySyncResponse(objects: [], errors: [error]))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<LanguageCodable>, Never> {
        
        return getLanguages(requestPriority: requestPriority)
            .map { (languages: [LanguageCodable]) in
                return RepositorySyncResponse(objects: languages, errors: [])
            }
            .catch { (error: Error) in
                return Just(RepositorySyncResponse(objects: [], errors: [error]))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
