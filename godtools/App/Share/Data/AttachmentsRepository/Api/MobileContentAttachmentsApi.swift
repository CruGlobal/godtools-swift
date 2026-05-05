//
//  MobileContentAttachmentsApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync

final class MobileContentAttachmentsApi {
    
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    func getAttachmentFile(url: URL, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlRequest: URLRequest = URLRequest(url: url)
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
