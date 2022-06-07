//
//  MobileContentTranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentTranslationsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    let session: URLSession
    
    required init(config: ConfigType, sharedSession: SharedSessionType) {
                    
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func newTranslationZipDataRequest(translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/translations/" + translationId,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func newTranslationZipDataOperation(translationId: String) -> RequestOperation {
        
        let urlRequest = newTranslationZipDataRequest(translationId: translationId)
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
    
    func getTranslationZipData(translationId: String, complete: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let translationZipDataOperation = newTranslationZipDataOperation(translationId: translationId)
        
        let queue = OperationQueue()
                
        translationZipDataOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([translationZipDataOperation], waitUntilFinished: false)
        
        return queue
    }
    
    func getTranslationsZipData(translationIds: [String], didDownloadTranslation: @escaping ((_ translationId: String, _ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void), completion: @escaping (() -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [RequestOperation] = Array()
        
        for translationId in translationIds {
            
            guard !translationId.isEmpty else {
                continue
            }
            
            let operation: RequestOperation = newTranslationZipDataOperation(translationId: translationId)
                    
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
