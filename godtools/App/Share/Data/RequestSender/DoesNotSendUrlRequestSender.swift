//
//  DoesNotSendUrlRequestSender.swift
//  godtools
//
//  Created by Levi Eggert on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class DoesNotSendUrlRequestSender: RequestSenderInterface {
    
    private func getFakeResponse() throws -> RequestDataResponse {
        
        let stringData = "String data"
        let data: Data = stringData.data(using: .utf8) ?? Data()
        
        guard let url = URL(string: "https://mobile-content-api.cru.org") else {
            throw NSError.errorWithDescription(description: "Failed to create URL with string")
        }

        let urlResponse: URLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let response = RequestDataResponse(data: data, urlResponse: urlResponse)
        
        return response
    }
    
    func sendDataTask(urlRequest: URLRequest, urlSession: URLSession) async throws -> RequestDataResponse {
        
        return try getFakeResponse()
    }
}
