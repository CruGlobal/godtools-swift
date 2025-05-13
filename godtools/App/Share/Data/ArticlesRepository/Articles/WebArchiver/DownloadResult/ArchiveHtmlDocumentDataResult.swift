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
    let error: WebArchiveOperationError?
    
    init(data: HTMLDocumentData?, error: WebArchiveOperationError?) {
        
        self.data = data
        self.error = error
    }
}
