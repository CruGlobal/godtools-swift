//
//  ArticleAemCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ArticleAemCacheError: Error, Sendable {
    
    case failedToUpdateRealmArticleAemData(error: Error)
    case failedToRemoveWebArchivePlistData(error: Error)
    case failedToCacheWebArchivePlistData(error: Error)
}
