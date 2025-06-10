//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentTranslationsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let baseUrl: String
    
    required init(config: AppConfig, urlSessionPriority: GetUrlSessionPriorityInterface) {
                    
        self.urlSessionPriority = urlSessionPriority
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Files
    
    private func getTranslationFileRequest(urlSession: URLSession, fileName: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/translations/files/" + fileName,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationFile(fileName: String, sendRequestPriority: SendRequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let urlRequest: URLRequest = getTranslationFileRequest(urlSession: urlSession, fileName: fileName)
                
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .validate()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Translation Zip File Data
    
    private func getTranslationZipFileRequest(urlSession: URLSession, translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/translations/" + translationId,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationZipFile(translationId: String, sendRequestPriority: SendRequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(urlSession: urlSession, translationId: translationId)
                
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .validate()
            .eraseToAnyPublisher()
    }
}
