//
//  EmailSignUpApi.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class EmailSignUpApi {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: URLSessionPriority
    private let baseUrl: String = "https://campaign-forms.cru.org"
    private let campaignId: String = "3fb6022c-5ef9-458c-928a-0380c4a0e57b"
    
    init(urlSessionPriority: URLSessionPriority) {
        
        self.urlSessionPriority = urlSessionPriority
    }
    
    private func getEmailSignUpRequest(emailSignUp: EmailSignUpModelType, urlSession: URLSession) -> URLRequest {
        
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
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/forms",
                method: .post,
                headers: ["Content-Type": "application/json"],
                httpBody: body,
                queryItems: nil
            )
        )
        
        return request
    }
    
    func postEmailSignUpPublisher(emailSignUp: EmailSignUpModelType, requestPriority: RequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = getEmailSignUpRequest(emailSignUp: emailSignUp, urlSession: urlSession)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .eraseToAnyPublisher()
    }
}
