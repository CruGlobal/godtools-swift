//
//  ArticleAemDataObjectsThatNeedDownloading.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ArticleAemDataObjectsThatNeedDownloading {
    
    let aemDataDictionary: [ArticleAemCache.AemUri: ArticleAemData]
    let webArchiveUrls: [WebArchiveUrl]
}
