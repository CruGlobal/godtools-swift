//
//  MobileContentAttachmentsApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class MobileContentAttachmentsApi {
    
    private let requestSender: RequestSender = RequestSender()
    private let urlSessionPriority: URLSessionPriority
    private let baseUrl: String
    
    init(config: AppConfig, urlSessionPriority: URLSessionPriority) {
                    
        self.urlSessionPriority = urlSessionPriority
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    func getAttachmentFile(url: URL, requestPriority: RequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)

        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: urlSession)
            .validate()
            .eraseToAnyPublisher()
    }
}
