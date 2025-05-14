//
//  ArticleAemRepositoryResult.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ArticleAemRepositoryResult {
    
    let downloaderResult: ArticleAemDownloaderResult
    let cacheResult: ArticleAemCacheResult
}

extension ArticleAemRepositoryResult {
    
    static func emptyResult() -> ArticleAemRepositoryResult {
        return ArticleAemRepositoryResult(
            downloaderResult: ArticleAemDownloaderResult(aemDataObjects: [], aemDownloadErrors: []),
            cacheResult: ArticleAemCacheResult(numberOfArchivedObjects: 0, cacheErrorData: [], saveAemDataToRealmError: nil)
        )
    }
}
