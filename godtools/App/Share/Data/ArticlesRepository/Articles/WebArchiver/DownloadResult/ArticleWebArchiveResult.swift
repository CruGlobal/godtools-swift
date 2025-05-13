//
//  ArticleWebArchiveResult.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ArticleWebArchiveResult {
    
    let data: ArticleWebArchiveData?
    let error: WebArchiveOperationError?
    
    init(data: ArticleWebArchiveData?, error: WebArchiveOperationError?) {
        
        self.data = data
        self.error = error
    }
}
