//
//  ArticleManager.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

enum ArticleError: LocalizedError {
    
    case requestMetadataFailed(resourceURLString: String, error: Error)
    case invalidMetadataJSON
    case invalidURL
    case downloadingWebPage(pageURLString: String, error: Error)
    
    var errorDescription: String? {
        switch self {
        case .requestMetadataFailed(let string, _): return "Metadata downloading failed: " + string
        case .invalidMetadataJSON: return "Invalid JSON metadata."
        case .invalidURL: return "Invalid URL"
        case .downloadingWebPage(let urls, let err): return "Downloading page" + urls + ": error:" + err.localizedDescription
        }
    }
}
