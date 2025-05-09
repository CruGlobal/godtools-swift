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
    
    private let priorityRequestSender: PriorityRequestSenderInterface
    private let ignoreCacheSession: IgnoreCacheSession
    private let baseUrl: String
    
    init(config: AppConfig, priorityRequestSender: PriorityRequestSenderInterface, ignoreCacheSession: IgnoreCacheSession) {
                    
        self.priorityRequestSender = priorityRequestSender
        self.ignoreCacheSession = ignoreCacheSession
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    func getAttachmentFile(url: URL, sendRequestPriority: SendRequestPriority) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let requestSender: RequestSender = priorityRequestSender.createRequestSender(sendRequestPriority: sendRequestPriority)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: ignoreCacheSession.session)
            .validate()
            .eraseToAnyPublisher()
    }
}
