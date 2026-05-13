//
//  ArticleAemDownload.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ArticleAemDownload: Sendable {
    
    let aemDataObjects: [ArticleAemData]
    let errors: [Error]
    
    func copy(errors: [Error]?) -> ArticleAemDownload {
        return ArticleAemDownload(
            aemDataObjects: aemDataObjects,
            errors: errors ?? self.errors
        )
    }
    
    func copyByAppendingErrors(errors: [Error]) -> ArticleAemDownload {
        return ArticleAemDownload(
            aemDataObjects: aemDataObjects,
            errors: self.errors + errors
        )
    }
}
