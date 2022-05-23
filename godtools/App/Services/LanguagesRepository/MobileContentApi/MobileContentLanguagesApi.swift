//
//  MobileContentLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentLanguagesApi {
    
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
    
    func getLanguages(complete: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
        
        let queue = OperationQueue()
        
        languagesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<NoHttpClientSuccessResponse, NoHttpClientErrorResponse> = response.getResult()
            
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
    
    func getLanguages(complete: @escaping ((_ result: Result<[LanguageModel], RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
        
        let queue = OperationQueue()
        
        languagesOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<LanguagesDataModel, NoHttpClientErrorResponse> = response.getResult()
            
            switch result {
            case .success( let languagesData, let decodeError):
                if let decodeError = decodeError {
                    assertionFailure("MobileContentLanguagesApi: Failed to decode languages: \(decodeError)")
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
