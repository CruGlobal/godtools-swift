//
//  WebArchiveOperationResult.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebArchiveOperationResult {
    
    let webArchiveUrl: WebArchiveUrl
    let webArchivePlistData: Data
    
    init(webArchiveUrl: WebArchiveUrl, webArchivePlistData: Data) {
        
        self.webArchiveUrl = webArchiveUrl
        self.webArchivePlistData = webArchivePlistData
    }
}
