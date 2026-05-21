//
//  MobileContentAttachmentsApi.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentAttachmentsApi: AttachmentsApiInterface {
    
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSenderInterface
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSenderInterface) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
        baseUrl = config.getMobileContentApiBaseUrl()
    }
    
    func getAttachmentFile(url: URL, requestPriority: RequestPriority) async throws -> RequestDataResponse {
        
        let urlRequest: URLRequest = try URLRequest(url: url)
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        return try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
    }
}
