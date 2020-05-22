//
//  ArticleAemImportServiceError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemImportServiceError: Error {
    
    enum Reason {
        
        case cancelled
        case failedToCacheAemImportDataToRealm
        case failedToCacheWebArchivePlistData(cacheWebArchivePlistDataErrors: [Error])
        case noNetworkConnection
        case webArchiveOperationsFailed(webArchiveOperationErrors: [WebArchiveOperationError])
    }
    
    let error: Error
    let reason: Reason
}
