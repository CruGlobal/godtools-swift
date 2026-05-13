//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentTranslationsApi: TranslationsApiInterface {
    
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
    
    func getTranslationFile(fileName: String, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getTranslationFileRequest(urlSession: urlSession, fileName: fileName)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
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
    
    func getTranslationZipFile(translationId: String, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(urlSession: urlSession, translationId: translationId)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
