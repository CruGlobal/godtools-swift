//
//  PersonalizedToolsApi.swift
//  godtools
//
//  Created by Levi Eggert on 1/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class PersonalizedToolsApi: PersonalizedToolsApiInterface {
    
    enum QueryName: String {
        case country = "country"
        case language = "lang"
        case resourceType = "resource-type"
    }
        
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSenderInterface
    private let baseUrl: String

    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSenderInterface) {

        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: -
    
    private func buildResourceTypeQueryItems(resourceTypes: [ResourceType]?) -> [URLQueryItem] {

        guard let resourceTypes = resourceTypes, !resourceTypes.isEmpty else { return [] }

        return resourceTypes.map { resourceType in
            URLQueryItem(name: "filter[\(QueryName.resourceType.rawValue)][]", value: resourceType.rawValue)
        }
    }
    
    // MARK: - Default
    
    private func getDefaultOrderUrlRequest(
        urlSession: URLSession,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) throws -> URLRequest {

        var queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.language.rawValue: [language]
            ]
        )

        let resourceTypeQueryItems: [URLQueryItem] = buildResourceTypeQueryItems(resourceTypes: resourceTypes)
        queryItems?.append(contentsOf: resourceTypeQueryItems)

        return try requestBuilder
            .build(
                parameters: try RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/default-order",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: queryItems
                )
            )
    }
    
    func getDefaultOrderResources(
        requestPriority: RequestPriority,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) async throws -> [ResourceCodable] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = try getDefaultOrderUrlRequest(
            urlSession: urlSession,
            language: language,
            resourceTypes: resourceTypes
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let codableResponse: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResponse.successCodable?.dataArray ?? []
    }
    
    // MARK: - Featured
    
    private func getFeaturedUrlRequest(
        urlSession: URLSession,
        country: TwoLetterCountryCode,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) throws -> URLRequest {

        var queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.country.rawValue: [country],
                QueryName.language.rawValue: [language]
            ]
        )

        let resourceTypeQueryItems: [URLQueryItem] = buildResourceTypeQueryItems(resourceTypes: resourceTypes)
        queryItems?.append(contentsOf: resourceTypeQueryItems)

        return try requestBuilder
            .build(
                parameters: try RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/featured",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: queryItems
                )
            )
    }

    func getFeaturedResources(
        requestPriority: RequestPriority,
        country: TwoLetterCountryCode,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) async throws -> [ResourceCodable] {

        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)

        let urlRequest: URLRequest = try getFeaturedUrlRequest(
            urlSession: urlSession,
            country: country,
            language: language,
            resourceTypes: resourceTypes
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let codableResponse: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResponse.successCodable?.dataArray ?? []
    }
    
    // MARK: - Ranked
    
    private func getRankedUrlRequest(
        urlSession: URLSession,
        country: TwoLetterCountryCode,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) throws -> URLRequest {

        var queryItems: [URLQueryItem]? = JsonApiFilter.buildQueryItems(
            nameValues: [
                QueryName.country.rawValue: [country],
                QueryName.language.rawValue: [language]
            ]
        )

        let resourceTypeQueryItems: [URLQueryItem] = buildResourceTypeQueryItems(resourceTypes: resourceTypes)
        queryItems?.append(contentsOf: resourceTypeQueryItems)

        return try requestBuilder
            .build(
                parameters: try RequestBuilderParameters(
                    configuration: urlSession.configuration,
                    urlString: baseUrl + "/resources/ranked",
                    method: .get,
                    headers: nil,
                    httpBody: nil,
                    queryItems: queryItems
                )
            )
    }

    func getRankedResources(
        requestPriority: RequestPriority,
        country: TwoLetterCountryCode,
        language: TwoLetterLanguageCode,
        resourceTypes: [ResourceType]?
    ) async throws -> [ResourceCodable] {

        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)

        let urlRequest: URLRequest = try getRankedUrlRequest(
            urlSession: urlSession,
            country: country,
            language: language,
            resourceTypes: resourceTypes
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(urlRequest: urlRequest, urlSession: urlSession)
        
        let codableResponse: RequestCodableResponse<JsonApiResponseDataArray<ResourceCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return codableResponse.successCodable?.dataArray ?? []
    }
}
