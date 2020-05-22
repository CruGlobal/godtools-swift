//
//  ArticleAemImportServiceError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticleAemImportServiceError: Error {
    
    case apiError(error: ArticleAemImportApiError)
    case failedToCacheAemImportDataToRealm(error: Error)
    case failedToCacheWebArchivePlistData(cacheWebArchivePlistDataErrors: [Error])
    case webArchiveOperationsFailed(webArchiveOperationErrors: [WebArchiveOperationError])
}
