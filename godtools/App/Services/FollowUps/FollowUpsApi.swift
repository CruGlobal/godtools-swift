//
//  FollowUpsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class FollowUpsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let session: URLSession
    private let baseUrl: String
    
    required init(config: AppConfig, sharedSession: SharedIgnoreCacheSession) {
        
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func newFollowUpsRequest(followUp: FollowUpModelType) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "follow-up",
                "attributes": [
                    "name": followUp.name,
                    "email": followUp.email,
                    "destination_id": followUp.destinationId,
                    "language_id": followUp.languageId
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/follow_ups",
            method: .post,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
    
    func newFollowUpsOperation(followUp: FollowUpModelType) -> RequestOperation {
        
        let urlRequest = newFollowUpsRequest(followUp: followUp)
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
    
    func postFollowUp(followUp: FollowUpModelType, complete: @escaping ((_ response: RequestResponse) -> Void)) -> OperationQueue {
        
        let operation: RequestOperation = newFollowUpsOperation(followUp: followUp)
        
        operation.setCompletionHandler { (response: RequestResponse) in
            
            complete(response)
        }
        
        let queue = OperationQueue()
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
}
