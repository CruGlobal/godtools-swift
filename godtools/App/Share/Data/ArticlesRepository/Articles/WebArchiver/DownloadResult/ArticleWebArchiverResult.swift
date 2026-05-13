//
//  ArticleWebArchiverResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleWebArchiverResult: Sendable {
    
    let archives: [ArticleWebArchiveData]
    let errors: [Error]
    
    var networkFailed: Bool {
        
        for error in errors {
            if error.isUrlErrorNotConnectedToInternetCode {
                return true
            }
        }
        
        return false
    }
}

extension ArticleWebArchiverResult {
    
    static var emptyValue: ArticleWebArchiverResult {
        
        return ArticleWebArchiverResult(
            archives: [],
            errors: []
        )
    }
}
