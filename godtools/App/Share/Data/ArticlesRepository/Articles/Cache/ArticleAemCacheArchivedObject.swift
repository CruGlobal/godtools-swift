//
//  ArticleAemCacheArchivedObject.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ArticleAemCacheArchivedObject: Sendable {
    
    let aemData: ArticleAemData
    let webArchivePlistData: Data
}
