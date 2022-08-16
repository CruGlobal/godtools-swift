//
//  ViewsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class ViewsApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let session: URLSession
    private let baseUrl: String
    
    required init(config: AppConfig, sharedSession: SharedSessionType) {
                    
        session = sharedSession.session
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func newResourceViewRequest(resourceView: ResourceViewModelType) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "view",
                "attributes": [
                    "resource_id": resourceView.resourceId,
                    "quantity": resourceView.quantity
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/views",
            method: .post,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
    
    func newResourceViewOperation(resourceView: ResourceViewModelType) -> RequestOperation {
        
        let urlRequest = newResourceViewRequest(resourceView: resourceView)
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
    
    func postResourceView(resourceView: ResourceViewModelType, complete: @escaping ((_ response: RequestResponse) -> Void)) -> OperationQueue {
        
        let operation: RequestOperation = newResourceViewOperation(resourceView: resourceView)
        
        operation.setCompletionHandler { (response: RequestResponse) in
            
            complete(response)
        }
        
        let queue = OperationQueue()
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
}
