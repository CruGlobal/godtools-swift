//
//  PersonalizedToolsApi.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PersonalizedToolsApi {
    
    enum QueryName: String {
        case country = "country"
        case language = "lang"
        case resourceType = "resource_type"
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
    
    private func getAllRankedResourcesUrlRequest(urlSession: URLSession, country: String?, language: String?, resouceType: ResourceType?) -> URLRequest {
        
        let queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.country.rawValue: [country],
                QueryName.language.rawValue: [language],
                QueryName.resourceType.rawValue: [resouceType?.rawValue]
            ]
        )
        
        return requestBuilder
            .build(
                parameters: RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/featured",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: queryItems
                )
            )
    }
    
    private func getDefaultOrderResourcesUrlRequest(urlSession: URLSession, language: String?, resouceType: ResourceType?) -> URLRequest {
        
        let queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.language.rawValue: [language],
                QueryName.resourceType.rawValue: [resouceType?.rawValue]
            ]
        )
        
        return requestBuilder
            .build(
                parameters: RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/default_order",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: queryItems
                )
            )
    }
    
    func getAllRankedResources(requestPriority: RequestPriority, country: String?, language: String?, resouceType: ResourceType?) async throws -> [ResourceCodable] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getAllRankedResourcesUrlRequest(
            urlSession: urlSession,
            country: country,
            language: language,
            resouceType: resouceType
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let codableResponse: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResponse.successCodable?.dataArray ?? []
    }
    
    func getDefaultOrderResources(requestPriority: RequestPriority, language: String?, resouceType: ResourceType?) async throws -> [ResourceCodable] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getDefaultOrderResourcesUrlRequest(
            urlSession: urlSession,
            language: language,
            resouceType: resouceType
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let codableResponse: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResponse.successCodable?.dataArray ?? []
    }
}
