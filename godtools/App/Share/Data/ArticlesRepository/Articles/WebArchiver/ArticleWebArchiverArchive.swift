//
//  ArticleWebArchiverArchive.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ArticleWebArchiverArchive: Sendable {
    
    let archives: [ArticleWebArchiveData]
    let errors: [Error]
}

extension ArticleWebArchiverArchive {
    
    var networkFailed: Bool {
        
        for error in errors {
            if error.isUrlErrorNotConnectedToInternetCode {
                return true
            }
        }
        
        return false
    }
    
    static var emptyValue: ArticleWebArchiverArchive {
        
        return ArticleWebArchiverArchive(
            archives: [],
            errors: []
        )
    }
}
