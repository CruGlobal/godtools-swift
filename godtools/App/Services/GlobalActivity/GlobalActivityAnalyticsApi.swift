//
//  GlobalActivityAnalyticsApi.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class GlobalActivityAnalyticsApi {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: AppConfig, sharedSession: SharedSessionType) {
        
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
        
    private func newGlobalAnalyticsOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/analytics/global",
            method: .get,
            headers: nil,
            httpBody: nil,
            queryItems: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }

    func getGlobalAnalytics(complete: @escaping ((_ result: Result<GlobalActivityAnalytics?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let globalAnalyticsOperation = newGlobalAnalyticsOperation()
        
        let queue = OperationQueue()
        
        globalAnalyticsOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<GlobalActivityAnalytics, NoHttpClientErrorResponse> = response.getResult()
                        
            switch result {
            case .success(let globalActivityAnalytics, let decodeError):
                complete(.success(globalActivityAnalytics))
                if let decodeError = decodeError {
                    assertionFailure("GlobalActivityAnalyticsApi failed to decode global activity analytics with error: \(decodeError)")
                }
            case .failure(let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([globalAnalyticsOperation], waitUntilFinished: false)
        
        return queue
    }
}
