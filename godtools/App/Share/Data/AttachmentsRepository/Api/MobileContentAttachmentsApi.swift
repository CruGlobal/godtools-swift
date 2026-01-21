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
import Combine

class MobileContentAttachmentsApi {
    
    private let urlSessionPriority: URLSessionPriority
    private let requestSender: RequestSender
    private let baseUrl: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, requestSender: RequestSender) {
                    
        self.urlSessionPriority = urlSessionPriority
        self.requestSender = requestSender
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

// MARK: - ExternalDataFetchInterface

extension MobileContentAttachmentsApi: ExternalDataFetchInterface {
    
    func getObject(id: String, context: ExternalDataFetchContext) async throws -> [AttachmentCodable] {
        return Array()
    }
    
    func getObjects(context: ExternalDataFetchContext) async throws -> [AttachmentCodable] {
        return Array()
    }
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[AttachmentCodable], Error> {
        return emptyResponsePublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[AttachmentCodable], Error> {
        return emptyResponsePublisher()
    }
}
