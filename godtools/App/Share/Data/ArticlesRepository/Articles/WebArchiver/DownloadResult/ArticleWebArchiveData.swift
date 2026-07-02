//
//  ArticleWebArchiveData.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ArticleWebArchiveData: Sendable {
    
    let webArchiveUrl: WebArchiveUrl
    let webArchivePlistData: Data
}
