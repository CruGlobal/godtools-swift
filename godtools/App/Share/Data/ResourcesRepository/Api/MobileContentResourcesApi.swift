//
//  MobileContentResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentResourcesApi: ResourcesApiInterface {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
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
    
    func getResourcePlusLatestTranslationsAndAttachments(id: String, requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(
            urlSession: urlSession,
            id: id
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        ).validate()
        
        let responseCodable: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsCodable, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessOrFailureCodable()
        
        let resources: ResourcesPlusLatestTranslationsAndAttachmentsCodable = responseCodable.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsCodable.emptyModel
        
        return resources
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
    
    func getResourcePlusLatestTranslationsAndAttachments(abbreviation: String, requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcePlusLatestTranslationsAndAttachmentsRequest(
            urlSession: urlSession,
            abbreviation: abbreviation
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        ).validate()
        
        let responseCodable: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsCodable, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessOrFailureCodable()
        
        let resources: ResourcesPlusLatestTranslationsAndAttachmentsCodable = responseCodable.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsCodable.emptyModel
        
        return resources
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
    
    func getResourcesPlusLatestTranslationsAndAttachments(requestPriority: RequestPriority) async throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getResourcesPlusLatestTranslationsAndAttachmentsRequest(urlSession: urlSession)
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        ).validate()
        
        let responseCodable: RequestCodableResponse<ResourcesPlusLatestTranslationsAndAttachmentsCodable, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        let resources: ResourcesPlusLatestTranslationsAndAttachmentsCodable = responseCodable.successCodable ?? ResourcesPlusLatestTranslationsAndAttachmentsCodable.emptyModel
        
        return resources
    }
}
