//
//  ResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class ResourcesApi {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: ConfigType, sharedSession: SharedSessionType) {
                    
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func newResourcesPlusLatestTranslationsAndAttachmentsOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/resources?include=latest-translations,attachments",
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let resourcesOperation: RequestOperation = newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        let queue = OperationQueue()
        
        resourcesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([resourcesOperation], waitUntilFinished: false)
        
        return queue
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((Result<ResourcesPlusLatestTranslationsAndAttachmentsModel?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let resourcesOperation: RequestOperation = newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        let queue = OperationQueue()
        
        resourcesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<ResourcesPlusLatestTranslationsAndAttachmentsModel, NoHttpClientErrorResponse> = response.getResult()
            
            switch result {
            case .success(let resourcesPlusLatestTranslationsAndAttachments, let decodeError):
                if let decodeError = decodeError {
                    assertionFailure("ResourcesApi: Failed to decode resources: \(decodeError)")
                }
                complete(.success(resourcesPlusLatestTranslationsAndAttachments))
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([resourcesOperation], waitUntilFinished: false)
        
        return queue
    }
}
