//
//  EmailSignUpApi.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class EmailSignUpApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String = "https://campaign-forms.cru.org"
    private let campaignId: String = "3fb6022c-5ef9-458c-928a-0380c4a0e57b"
    
    let session: URLSession
    
    required init(sharedSession: SharedSessionType) {
        
        session = sharedSession.session
    }
        
    func postEmailSignUp(email: String, firstName: String?, lastName: String?, complete: @escaping ((_ response: RequestResponse, _ result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) -> Void)) -> OperationQueue {
        
        var body: [String: String] = Dictionary()
        
        body["id"] = campaignId
        body["email_address"] = email
        if let firstName = firstName {
            body["first_name"] = firstName
        }
        if let lastName = lastName {
            body["last_name"] = lastName
        }
        
        let request: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/forms",
            method: .post,
            headers: nil,
            httpBody: body
        )
        
        let operation = RequestOperation(
            session: session,
            urlRequest: request
        )
        
        return SingleRequestOperation().execute(operation: operation, completeOnMainThread: false) { (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
            
            complete(response, result)
        }
    }
}
