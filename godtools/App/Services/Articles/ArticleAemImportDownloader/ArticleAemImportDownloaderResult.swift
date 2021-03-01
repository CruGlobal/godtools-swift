//
//  ArticleAemImportDownloaderResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemImportDownloaderResult {
    
    let resourceId: String
    let languageCode: String
    let articleAemImportDataObjects: [ArticleAemImportData]
    let articleAemImportErrors: [ArticleAemImportOperationError]
    let deleteWebArchiveDirectoryError: Error? // TODO: Is this property still needed? ~Levi
    let deleteArticleAemImportDataObjectsError: Error?
    let cacheArticleAemImportDataObjectsError: Error?
    let cacheWebArchivePlistDataErrors: [CacheArticleAemWebArchivePlistError]
    let webArchiveQueueResult: WebArchiveQueueResult
    let cancelled: Bool
    
    var downloadError: ArticleAemImportDownloaderError? {
        
        if cancelled {
            return .cancelled
        }
        
        for articleAemImportError in articleAemImportErrors {
            
            if articleAemImportError.cancelled {
                return .cancelled
            }
            else if articleAemImportError.networkFailed {
                return .noNetworkConnection
            }
            else if articleAemImportError.unknownError {
                return .unknownError
            }
        }
        
        for webArchiveOperationError in webArchiveQueueResult.failedArchives {
            
            if webArchiveOperationError.cancelled {
                return .cancelled
            }
            else if webArchiveOperationError.networkFailed {
                return .noNetworkConnection
            }
            else if webArchiveOperationError.unknownError {
                return .unknownError
            }
        }
        
        return nil
    }
}
