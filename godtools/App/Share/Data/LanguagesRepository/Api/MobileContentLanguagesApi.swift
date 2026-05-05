//
//  MobileContentLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentLanguagesApi {
    
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
    
    func getLanguage(requestPriority: RequestPriority, languageId: String) async throws -> LanguageCodable? {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getLanguageRequest(urlSession: urlSession, languageId: languageId)
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        _ = try response.validate()
        
        let decodeResponse: RequestCodableResponse<JsonApiResponseDataObject<LanguageCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return decodeResponse.successCodable?.dataObject
    }
    
    func getLanguages(requestPriority: RequestPriority) async throws -> [LanguageCodable] {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getLanguagesRequest(urlSession: urlSession)
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        _ = try response.validate()
        
        let decodeResponse: RequestCodableResponse<JsonApiResponseDataArray<LanguageCodable>, NoResponseCodable> = try response.decodeRequestDataResponseForSuccessCodable()
        
        return decodeResponse.successCodable?.dataArray ?? []
    }
}
