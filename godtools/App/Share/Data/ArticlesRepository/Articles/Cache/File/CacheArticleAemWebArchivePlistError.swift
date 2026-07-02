//
//  CacheArticleAemWebArchivePlistError.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct CacheArticleAemWebArchivePlistError: Sendable {
    
    let webArchiveFilename: String
    let url: URL
    let error: Error
}
