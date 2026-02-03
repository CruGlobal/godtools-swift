//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync
import Combine

class MobileContentTranslationsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
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
    
    func getTranslationFile(fileName: String, requestPriority: RequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
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
    
    func getTranslationZipFile(translationId: String, requestPriority: RequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(urlSession: urlSession, translationId: translationId)
                
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .validate()
            .eraseToAnyPublisher()
    }
}

// MARK: - ExternalDataFetchInterface

extension MobileContentTranslationsApi: ExternalDataFetchInterface {
    
    func getObject(id: String, context: ExternalDataFetchContext) async throws -> [TranslationCodable] {
        return Array()
    }
    
    func getObjects(context: ExternalDataFetchContext) async throws -> [TranslationCodable] {
        return Array()
    }
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[TranslationCodable], Error> {
        return emptyResponsePublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[TranslationCodable], Error> {
        return emptyResponsePublisher()
    }
}
