//
//  MobileContentGlobalAnalyticsApi.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentGlobalAnalyticsApi {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    init(baseUrl: String, ignoreCacheSession: IgnoreCacheSession) {
        
        session = ignoreCacheSession.session
        self.baseUrl = baseUrl
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

    func getGlobalAnalytics(complete: @escaping ((_ result: Result<MobileContentGlobalAnalyticsDataModel?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue {
        
        let globalAnalyticsOperation = newGlobalAnalyticsOperation()
        
        let queue = OperationQueue()
        
        globalAnalyticsOperation.setCompletionHandler { (response: RequestResponse) in
                        
            let result: RequestResponseResult<MobileContentGlobalAnalyticsDataModel, NoHttpClientErrorResponse> = response.getResult()
                        
            switch result {
            case .success(let dataModel, let decodeError):
                complete(.success(dataModel))
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
