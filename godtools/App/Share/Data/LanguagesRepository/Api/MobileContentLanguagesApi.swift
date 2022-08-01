//
//  MobileContentLanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentLanguagesApi {
    
    private enum Path {
        static let languages = "/languages"
    }
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
            
        session = ignoreCacheSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func getLanguagesRequest() -> URLRequest {
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + Path.languages,
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
    }
    
    func getLanguages() -> AnyPublisher<[LanguageModel], URLResponseError> {
        
        return session.dataTaskPublisher(for: getLanguagesRequest())
            .tryMap {
                
                let urlResponseObject = URLResponseObject(data: $0.data, urlResponse: $0.response)
                
                guard urlResponseObject.isSuccessHttpStatusCode else {
                    throw URLResponseError.statusCode(urlResponseObject: urlResponseObject)
                }
                
                return urlResponseObject.data
            }
            .mapError {
                return URLResponseError.requestError(error: $0 as Error)
            }
            .decode(type: LanguagesDataModel.self, decoder: JSONDecoder())
            .map {
                return $0.data
            }
            .mapError {
                return URLResponseError.decodeError(error: $0)
            }
            .eraseToAnyPublisher()
    }
    
    @available(*, deprecated) // TODO: Remove once switched over to using Combine publishers. ~Levi
    func getLanguagesOperation() -> RequestOperation {
        
        return RequestOperation(session: session, urlRequest: getLanguagesRequest())
    }
    
    @available(*, deprecated) // TODO: Remove once switched over to using Combine publishers. ~Levi
    func getLanguages(complete: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = getLanguagesOperation()
        
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
    
    @available(*, deprecated) // TODO: Remove once switched over to using Combine publishers. ~Levi
    func getLanguages(complete: @escaping ((_ result: Result<[LanguageModel], RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = getLanguagesOperation()
        
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
