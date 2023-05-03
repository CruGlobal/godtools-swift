//
//  ArticleAemDownloaderResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemDownloaderResult {
    
    let aemDataObjects: [ArticleAemData]
    let aemDownloadErrors: [ArticleAemDownloadOperationError]
        
    var downloadError: ArticleAemDownloaderError? {
        
        for downloadError in aemDownloadErrors {
            
            if downloadError.cancelled {
                return .cancelled
            }
            else if downloadError.networkFailed {
                return .noNetworkConnection
            }
            else if downloadError.unknownError {
                return .unknownError
            }
        }
        
        return nil
    }
}
