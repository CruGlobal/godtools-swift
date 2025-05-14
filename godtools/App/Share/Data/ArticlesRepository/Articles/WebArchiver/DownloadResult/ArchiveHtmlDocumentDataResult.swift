//
//  ArchiveWebUrlResult.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Fuzi

class ArchiveHtmlDocumentDataResult {
    
    let data: HTMLDocumentData?
    let error: ArticleWebArchiveError?
    
    init(data: HTMLDocumentData?, error: ArticleWebArchiveError?) {
        
        self.data = data
        self.error = error
    }
}
