//
//  ArticleWebArchiverResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleWebArchiverResult {
    
    let successfulArchives: [ArticleWebArchiveData]
    let failedArchives: [ArticleWebArchiveError]
    let totalAttemptedArchives: Int
    
    init(successfulArchives: [ArticleWebArchiveData], failedArchives: [ArticleWebArchiveError], totalAttemptedArchives: Int) {
        
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

extension ArticleWebArchiverResult {
    
    static func getEmptyResult() -> ArticleWebArchiverResult {
        
        return ArticleWebArchiverResult(
            successfulArchives: [],
            failedArchives: [],
            totalAttemptedArchives: 0
        )
    }
}
