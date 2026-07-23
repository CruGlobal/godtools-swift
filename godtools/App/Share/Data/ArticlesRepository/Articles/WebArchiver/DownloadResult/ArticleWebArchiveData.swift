//
//  ArticleWebArchiveData.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ArticleWebArchiveData: Sendable {
    
    let webArchiveUrl: WebArchiveUrl
    let webArchivePlistData: Data?
    let error: Error?
    
    static func createWithData(webArchiveUrl: WebArchiveUrl, webArchivePlistData: Data) -> ArticleWebArchiveData {
        return ArticleWebArchiveData(webArchiveUrl: webArchiveUrl, webArchivePlistData: webArchivePlistData, error: nil)
    }
    
    static func createWithError(webArchiveUrl: WebArchiveUrl, error: Error) -> ArticleWebArchiveData {
        return ArticleWebArchiveData(webArchiveUrl: webArchiveUrl, webArchivePlistData: nil, error: error)
    }
}
