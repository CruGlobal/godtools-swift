//
//  EmailSignUpApi.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class EmailSignUpApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String = "https://campaign-forms.cru.org"
    private let campaignId: String = "3fb6022c-5ef9-458c-928a-0380c4a0e57b"
    
    let session: URLSession
    
    init(ignoreCacheSession: IgnoreCacheSession) {
        
        session = ignoreCacheSession.session
    }
    
    private func newEmailSignUpRequest(emailSignUp: EmailSignUpModelType) -> URLRequest {
        
        var body: [String: String] = Dictionary()
        
        body["id"] = campaignId
        body["email_address"] = emailSignUp.email
        if let firstName = emailSignUp.firstName {
            body["first_name"] = firstName
        }
        if let lastName = emailSignUp.lastName {
            body["last_name"] = lastName
        }
        
        let request: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/forms",
            method: .post,
            headers: ["Content-Type": "application/json"],
            httpBody: body,
            queryItems: nil
        )
        
        return request
    }
    
    func newEmailSignUpOperation(emailSignUp: EmailSignUpModelType) -> RequestOperation {
        
        let urlRequest: URLRequest = newEmailSignUpRequest(emailSignUp: emailSignUp)
        
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
        
    func postEmailSignUp(emailSignUp: EmailSignUpModelType, complete: @escaping ((_ response: RequestResponse) -> Void)) -> OperationQueue {
        
        let operation = newEmailSignUpOperation(emailSignUp: emailSignUp)
        
        operation.setCompletionHandler { (response: RequestResponse) in
            
            complete(response)
        }
        
        let queue = OperationQueue()
        
        queue.addOperations([operation], waitUntilFinished: false)
        
        return queue
    }
}
