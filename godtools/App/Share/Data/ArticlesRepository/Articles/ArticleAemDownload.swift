//
//  ArticleAemDownload.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ArticleAemDownload: Sendable {
    
    let aemDataObjects: [ArticleAemData]
    let webArchiveErrors: [Error]
    
    static var emptyValue: ArticleAemDownload {
        return ArticleAemDownload(aemDataObjects: [], webArchiveErrors: [])
    }
    
    var aemErrors: [Error] {
        return aemDataObjects.compactMap { $0.error }
    }
    
    var errors: [Error] {
        aemErrors + webArchiveErrors
    }
    
    var networkFailed: Bool {
        return errors.containsNetworkFailed
    }
}
