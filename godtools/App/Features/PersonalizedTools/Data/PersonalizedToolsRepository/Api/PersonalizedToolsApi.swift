//
//  PersonalizedToolsApi.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

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
    
    private func getAllRankedResourcesUrlRequest(urlSession: URLSession, country: String?, language: String?, resourceType: ResourceType?) -> URLRequest {
        
        let queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.country.rawValue: [country],
                QueryName.language.rawValue: [language],
                QueryName.resourceType.rawValue: [resourceType?.rawValue]
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
    
    func getAllRankedResourcesPublisher(requestPriority: RequestPriority, country: String?, language: String?, resourceType: ResourceType?) -> AnyPublisher<[ResourceCodable], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getAllRankedResourcesUrlRequest(
            urlSession: urlSession,
            country: country,
            language: language,
            resourceType: resourceType
        )
        
        return requestSender
            .sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable>) in
                
                let resources: [ResourceCodable] = response.successCodable?.dataArray ?? []
                return resources
            }
            .eraseToAnyPublisher()
    }
    
    func getDefaultOrderResourcesPublisher(requestPriority: RequestPriority, language: String?, resouceType: ResourceType?) -> AnyPublisher<[ResourceCodable], Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getDefaultOrderResourcesUrlRequest(
            urlSession: urlSession,
            language: language,
            resouceType: resouceType
        )
        
        return requestSender
            .sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .decodeRequestDataResponseForSuccessCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable>) in
                
                let resources: [ResourceCodable] = response.successCodable?.dataArray ?? []
                return resources
            }
            .eraseToAnyPublisher()
    }
}
