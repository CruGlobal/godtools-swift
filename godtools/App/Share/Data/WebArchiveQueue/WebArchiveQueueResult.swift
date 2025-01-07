//
//  WebArchiveQueueResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebArchiveQueueResult {
    
    let successfulArchives: [WebArchiveOperationResult]
    let failedArchives: [WebArchiveOperationError]
    let totalAttemptedArchives: Int
    
    init(successfulArchives: [WebArchiveOperationResult], failedArchives: [WebArchiveOperationError], totalAttemptedArchives: Int) {
        
        self.successfulArchives = successfulArchives
        self.failedArchives = failedArchives
        self.totalAttemptedArchives = totalAttemptedArchives
    }
    
    var networkFailed: Bool {
        
        for operationError in failedArchives where operationError.networkFailed {
            return true
        }
        
        return false
    }
}
