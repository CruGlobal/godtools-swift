//
//  DownloadArticleAemResult.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct DownloadArticleAemResult: Sendable {
    
    let data: ArticleAemData?
    let error: Error?
}
