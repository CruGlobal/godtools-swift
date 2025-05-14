//
//  ArticleWebArchiveData.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ArticleWebArchiveData {
    
    let webArchiveUrl: WebArchiveUrl
    let webArchivePlistData: Data
    
    init(webArchiveUrl: WebArchiveUrl, webArchivePlistData: Data) {
        
        self.webArchiveUrl = webArchiveUrl
        self.webArchivePlistData = webArchivePlistData
    }
}
