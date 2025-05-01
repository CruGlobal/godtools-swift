//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentTranslationsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender
    private let baseUrl: String
    
    required init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        requestSender = RequestSender(session: ignoreCacheSession.session)
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Translation
    
    private func getTranslationRequest(id: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/translations/\(id)",
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationPublisher(id: String) -> AnyPublisher<TranslationModel?, Error> {
        
        let urlRequest: URLRequest = getTranslationRequest(id: id)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .map { (response: RequestCodableResponse<JsonApiResponseDataObject<TranslationModel>, NoResponseCodable>) in
                
                return response.successCodable?.dataObject
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Files
    
    private func getTranslationFileRequest(fileName: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/translations/files/" + fileName,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationFile(fileName: String) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlRequest: URLRequest = getTranslationFileRequest(fileName: fileName)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .validate()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Translation Zip File Data
    
    private func getTranslationZipFileRequest(translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseUrl + "/translations/" + translationId,
                method: .get,
                headers: nil,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func getTranslationZipFile(translationId: String) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(translationId: translationId)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .validate()
            .eraseToAnyPublisher()
    }
}
