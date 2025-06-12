//
//  MobileContentResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentResourcesApi {
    
    private let requestSender: RequestSender = RequestSender()
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let baseUrl: String
    
    init(config: AppConfig, urlSessionPriority: URLSessionPriority) {
                    
        self.urlSessionPriority = urlSessionPriority
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Resource Plus Latest Translations And Attachments
    
    private func getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: URLSession, id: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/resources/\(id)?include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession, id: id)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
    
    private func getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: URLSession, abbreviation: String) -> URLRequest {
                
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/resources?filter[abbreviation]=\(abbreviation)&include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: String, requestPriority: RequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession, abbreviation: abbreviation)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Resources Plus Latest Translations And Attachments
    
    private func getResourcesPlusLatestTranslationsAndAttachmentsRequest(urlSession: URLSession) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/resources?filter[system]=GodTools&include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments(requestPriority: RequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcesPlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
}
