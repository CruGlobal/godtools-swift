//
//  TranslationsApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TranslationsApi: TranslationsApiType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: ConfigType) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
        
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func translationZipDataRequest(translationId: String) -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/translations/" + translationId,
            method: .get,
            headers: nil,
            httpBody: nil
        )
    }
    
    func getTranslationZipData(translationId: String, complete: @escaping ((_ response: RequestResponse, _ result: RequestResult<Data, NoRequestResultType>) -> Void)) -> OperationQueue {
        
        let urlRequest = translationZipDataRequest(translationId: translationId)
        
        let operation: RequestOperation<NoRequestResultType, NoRequestResultType> = RequestOperation(session: session, urlRequest: urlRequest)
        
        return operation.executeRequest { (response: RequestResponse, result: RequestResult<NoRequestResultType, NoRequestResultType>) in
                
            let dataResult: RequestResult<Data, NoRequestResultType>
            
            switch result {
            case .success( _):
                dataResult = .success(object: response.data)
            case .failure( _, let error):
                dataResult = .failure(clientError: nil, error: error)
            }
            
            DispatchQueue.main.async {
                complete(response, dataResult)
            }
        }
    }
}
