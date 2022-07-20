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
    
    required init(config: ConfigType, sharedSession: SharedSessionType) {
                    
        session = sharedSession.session
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
    
    func getTranslationFile(fileName: String) -> AnyPublisher<URLResponseObject, Error> {
        
        return session.dataTaskPublisher(for: getTranslationFileRequest(fileName: fileName))
            .map {
                return URLResponseObject(data: $0.data, urlResponse: $0.response)
            }
            .mapError {
                return $0 as Error
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
    
    func getTranslationZipFile(translationId: String) -> AnyPublisher<URLResponseObject, Error> {
        
        return session.dataTaskPublisher(for: getTranslationZipFileRequest(translationId: translationId))
            .map {
                return URLResponseObject(data: $0.data, urlResponse: $0.response)
            }
            .mapError {
                return $0 as Error
            }
            .eraseToAnyPublisher()
    }
        
    @available(*, deprecated) // This can be removed after removing TranslationDownload in place of TranslationsRepository following GT-1448. ~Levi
    func getTranslationZipFileDataOperation(translationId: String) -> RequestOperation {
        
        let urlRequest = getTranslationZipFileRequest(translationId: translationId)
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
    
    @available(*, deprecated) // This can be removed after removing TranslationDownload in place of TranslationsRepository following GT-1448. ~Levi
    func getTranslationZipFileData(translationId: String, completion: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let translationZipDataOperation = getTranslationZipFileDataOperation(translationId: translationId)
        
        let queue = OperationQueue()
                
        translationZipDataOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
            
            switch result {
            case .success( _, _):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        queue.addOperations([translationZipDataOperation], waitUntilFinished: false)
        
        return queue
    }
    
    @available(*, deprecated) // This can be removed after removing TranslationDownload in place of TranslationsRepository following GT-1448. ~Levi
    func getTranslationsZipFileData(translationIds: [String], didDownloadTranslation: @escaping ((_ translationId: String, _ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void), completion: @escaping (() -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [RequestOperation] = Array()
        
        for translationId in translationIds {
            
            let operation: RequestOperation = getTranslationZipFileDataOperation(translationId: translationId)
                    
            operations.append(operation)
            
            operation.setCompletionHandler { (response: RequestResponse) in
                                
                let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
                
                switch result {
                
                case .success( _, _):
                    didDownloadTranslation(translationId, .success(response.data))
                case .failure(let error):
                    didDownloadTranslation(translationId, .failure(error))
                }
                
                if queue.operations.isEmpty {
                    completion()
                }
            }
        }
        
        queue.addOperations(operations, waitUntilFinished: false)

        return queue
    }
}
