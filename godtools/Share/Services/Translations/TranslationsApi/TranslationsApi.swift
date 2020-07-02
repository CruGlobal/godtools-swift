//
//  TranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationsApi: TranslationsApiType {
    
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
            httpBody: nil
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
    
    func getTranslationZipData(translationId: String, complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let translationZipDataOperation = newTranslationZipDataOperation(translationId: translationId)
        
        return SingleRequestOperation().execute(operation: translationZipDataOperation, completeOnMainThread: true) { (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
}
