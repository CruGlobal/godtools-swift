//
//  DoesNotSendUrlRequestSender.swift
//  godtools
//
//  Created by Levi Eggert on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class DoesNotSendUrlRequestSender: RequestSender {
    
    override func sendDataTaskPublisher(urlRequest: URLRequest, urlSession: URLSession) -> AnyPublisher<RequestDataResponse, Error> {
                
        let stringData = "String data"
        let data: Data = stringData.data(using: .utf8) ?? Data()
        let urlResponse: URLResponse = HTTPURLResponse(url: URL(string: "https://mobile-content-api.cru.org")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let response = RequestDataResponse(data: data, urlResponse: urlResponse)
        
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
