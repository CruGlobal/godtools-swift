//
//  HTMLDocumentResource.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct HTMLDocumentResource: Sendable {
    
    let resource: WebArchiveResource?
    let error: Error?
    
    static func createWithResource(resource: WebArchiveResource) -> HTMLDocumentResource {
        return HTMLDocumentResource(resource: resource, error: nil)
    }
    
    static func createWithError(error: Error) -> HTMLDocumentResource {
        return HTMLDocumentResource(resource: nil, error: error)
    }
}
