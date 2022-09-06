//
//  WebArchiveQueue.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebArchiveQueue {
    
    private let session: URLSession
        
    required init(sharedSession: SharedIgnoreCacheSession) {
        
        self.session = sharedSession.session
    }
    
    deinit {

    }
    
    func archive(webArchiveUrls: [WebArchiveUrl], completion: @escaping ((_ webArchiveQueueResult: WebArchiveQueueResult) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [WebArchiveOperation] = Array()
        
        var successfulArchives: [WebArchiveOperationResult] = Array()
        var failedArchives: [WebArchiveOperationError] = Array()
        
        for webArchiveUrl in webArchiveUrls {
            
            let operation = WebArchiveOperation(session: session, webArchiveUrl: webArchiveUrl)
            
            operation.completionHandler { (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
                
                switch result {
                case .success(let operationResult):
                    successfulArchives.append(operationResult)
                case .failure(let operationError):
                    failedArchives.append(operationError)
                }
                                                
                if queue.operations.isEmpty {
                   
                    completion(WebArchiveQueueResult(successfulArchives: successfulArchives, failedArchives: failedArchives, totalAttemptedArchives: operations.count))
                }
            }
            
            operations.append(operation)
        }
        
        if !operations.isEmpty {
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            completion(WebArchiveQueueResult(successfulArchives: [], failedArchives: [], totalAttemptedArchives: 0))
        }
        
        return queue
    }
}
