//
//  ArticleAemCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ArticleAemCacheResult {
    
    let numberOfArchivedObjects: Int
    let cacheErrorData: [ArticleAemCacheErrorData]
}

extension ArticleAemCacheResult {
    
    static func emptyResult() -> ArticleAemCacheResult {
        return ArticleAemCacheResult(numberOfArchivedObjects: 0, cacheErrorData: [])
    }
}
