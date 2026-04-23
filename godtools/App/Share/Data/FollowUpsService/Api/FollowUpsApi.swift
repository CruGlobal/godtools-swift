//
//  FollowUpsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class FollowUpsApi: FollowUpsApiInterface {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(baseUrl: String, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
        
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        self.baseUrl = baseUrl
    }
    
    private func getFollowUpRequest(followUp: FollowUp, urlSession: URLSession) -> URLRequest {
        
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
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseUrl + "/follow_ups",
                method: .post,
                headers: headers,
                httpBody: body,
                queryItems: nil
            )
        )
    }
    
    func postFollowUp(followUp: FollowUp, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = getFollowUpRequest(followUp: followUp, urlSession: urlSession)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
