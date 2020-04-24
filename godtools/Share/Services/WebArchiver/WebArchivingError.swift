//
//  WebArchivingError.swift
//  godtools
//
//  Created by Igor Ostriz, based on work by Ernesto Elsäßer and BiblioArchiver
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

enum WebArchivingError: LocalizedError {
   
    case unsupportedUrl
    case requestFailed(resource: String, error: Error)
    case invalidResponse(resource: String)
    case unsupportedEncoding
    case invalidReferenceUrl(string: String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedUrl: return "Unsupported URL"
        case .requestFailed(let res, _): return "Failed to load " + res
        case .invalidResponse(let res): return "Invalid response for " + res
        case .unsupportedEncoding: return "Unsupported encoding"
        case .invalidReferenceUrl(let string): return "Invalid reference URL: " + string
        }
    }
}
