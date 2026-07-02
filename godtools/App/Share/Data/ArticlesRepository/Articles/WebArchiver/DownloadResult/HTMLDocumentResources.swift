//
//  HTMLDocumentResources.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct HTMLDocumentResources: Sendable {
    
    struct Result {
        let resource: WebArchiveResource?
        let error: Error?
    }
    
    let resources: [WebArchiveResource]
    let errors: [Error]
}
