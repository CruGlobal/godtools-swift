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
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let priorityRequestSender: PriorityRequestSenderInterface
    private let ignoreCacheSession: IgnoreCacheSession
    private let baseUrl: String
    
    init(config: AppConfig, priorityRequestSender: PriorityRequestSenderInterface, ignoreCacheSession: IgnoreCacheSession) {
                    
        self.priorityRequestSender = priorityRequestSender
        self.ignoreCacheSession = ignoreCacheSession
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
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: String, sendRequestPriority: SendRequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession, id: id)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
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
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: String, sendRequestPriority: SendRequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession, abbreviation: abbreviation)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
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
    
    func getResourcesPlusLatestTranslationsAndAttachments(sendRequestPriority: SendRequestPriority) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlSession: URLSession = ignoreCacheSession.session
        
        let urlRequest: URLRequest = getResourcesPlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
}
