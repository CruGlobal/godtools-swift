//
//  ArticleAemCacheObject.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ArticleAemCacheObject {
    
    let aemUri: String
    let aemData: ArticleAemData
    let webArchiveFileUrl: URL?
    let fetchWebArchiveFileUrlError: Error?
}
