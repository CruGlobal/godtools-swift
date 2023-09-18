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
    private let session: URLSession
    private let baseUrl: String
    
    required init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        session = ignoreCacheSession.session
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    // MARK: - Files
    
    private func getTranslationFileRequest(fileName: String) -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/translations/files/" + fileName,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func getTranslationFile(fileName: String) -> AnyPublisher<UrlRequestResponse, Error> {
        
        let urlRequest: URLRequest = getTranslationFileRequest(fileName: fileName)
        
        return session.sendUrlRequestPublisher(urlRequest: urlRequest)
            .mapError {
                return $0.error
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Translation Zip File Data
    
    private func getTranslationZipFileRequest(translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/translations/" + translationId,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func getTranslationZipFile(translationId: String) -> AnyPublisher<UrlRequestResponse, Error> {
        
        let urlRequest: URLRequest = getTranslationZipFileRequest(translationId: translationId)
        
        return session.sendUrlRequestPublisher(urlRequest: urlRequest)
            .mapError {
                return $0.error
            }
            .eraseToAnyPublisher()
    }
}
