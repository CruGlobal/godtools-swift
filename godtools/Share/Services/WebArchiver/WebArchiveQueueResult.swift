//
//  WebArchiveQueueResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct WebArchiveQueueResult {
    
    let successfulArchives: [WebArchiveOperationResult]
    let failedArchives: [WebArchiveOperationError]
    let totalAttemptedArchives: Int
    
    var networkFailed: Bool {
        for operationError in failedArchives {
            if operationError.networkFailed {
                return true
            }
        }
        return false
    }
}
