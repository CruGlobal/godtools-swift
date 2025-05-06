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
    private let ignoreCacheSession: IgnoreCacheSession
    private let baseUrl: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
                    
        self.ignoreCacheSession = ignoreCacheSession
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    func getAttachmentFile(url: URL) -> AnyPublisher<RequestDataResponse, Error> {
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest, urlSession: ignoreCacheSession.session)
            .validate()
            .eraseToAnyPublisher()
    }
}
