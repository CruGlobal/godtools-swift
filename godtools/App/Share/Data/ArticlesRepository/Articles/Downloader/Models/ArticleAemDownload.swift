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
    
    static var emptyValue: ArticleAemDownload {
        return ArticleAemDownload(aemDataObjects: [], errors: [])
    }
    
    var networkFailed: Bool {
        return firstErrorNotConnectedToInternet != nil
    }
    
    var firstErrorNotConnectedToInternet: Error? {
        for error in errors {
            if error.isUrlErrorNotConnectedToInternetCode {
                return error
            }
        }
        return nil
    }
    
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
