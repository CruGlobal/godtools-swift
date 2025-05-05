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
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        requestSender = RequestSender(session: ignoreCacheSession.session)
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Resource Plus Latest Translations And Attachments
    
    private func getResourcePlusLatestTranslationsAndAttachmentsRequest(id: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/resources/\(id)?include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(id: String) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(id: id)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
    
    private func getResourcePlusLatestTranslationsAndAttachmentsRequest(abbreviation: String) -> URLRequest {
                
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/resources?filter[abbreviation]=\(abbreviation)&include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcePlusLatestTranslationsAndAttachmentsPublisher(abbreviation: String) -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(abbreviation: abbreviation)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Resources Plus Latest Translations And Attachments
    
    private func getResourcesPlusLatestTranslationsAndAttachmentsRequest() -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/resources?filter[system]=GodTools&include=latest-translations,attachments",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments() -> AnyPublisher<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let urlRequest: URLRequest = getResourcesPlusLatestTranslationsAndAttachmentsRequest()
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoResponseCodable>) in
                
                let resources: ResourcesPlusLatestTranslationsAndAttachmentsModel = response.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsModel.emptyModel
                return resources
            }
            .eraseToAnyPublisher()
    }
}
