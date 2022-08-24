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
        baseUrl = config.mobileContentApiBaseUrl
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
    
    func getTranslationFile(fileName: String) -> AnyPublisher<URLResponseObject, URLResponseError> {
        
        return session.dataTaskPublisher(for: getTranslationFileRequest(fileName: fileName))
            .tryMap {
                
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject
            }
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
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
    
    func getTranslationZipFile(translationId: String) -> AnyPublisher<URLResponseObject, URLResponseError> {
        
        return session.dataTaskPublisher(for: getTranslationZipFileRequest(translationId: translationId))
            .tryMap {
                
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject
            }
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
            }
            .eraseToAnyPublisher()
    }
}
