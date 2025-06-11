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
    let error: ArticleWebArchiveError?
    
    init(data: ArticleWebArchiveData?, error: ArticleWebArchiveError?) {
        
        self.data = data
        self.error = error
    }
}
