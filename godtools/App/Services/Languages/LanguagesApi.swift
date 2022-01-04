//
//  LanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class LanguagesApi: LanguagesApiType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: ConfigType, sharedSession: SharedSessionType) {
            
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func newGetLanguagesOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/languages",
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    func getLanguages(complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
        
        let queue = OperationQueue()
        
        languagesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType> = response.getResult()
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([languagesOperation], waitUntilFinished: false)
        
        return queue
    }
    
    func getLanguages(complete: @escaping ((_ result: Result<[LanguageModel], ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
        
        let queue = OperationQueue()
        
        languagesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: ResponseResult<LanguagesDataModel, NoClientApiErrorType> = response.getResult()
            
            switch result {
            case .success( let languagesData, let decodeError):
                if let decodeError = decodeError {
                    assertionFailure("LanguagesApi: Failed to decode languages: \(decodeError)")
                }
                complete(.success(languagesData?.data ?? []))
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([languagesOperation], waitUntilFinished: false)
        
        return queue
    }
}
