//
//  WebArchiveOperationError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum WebArchiveOperationError: Error {
    
    case cancelled
    case failedEncodingPlistData(error: Error)
    case failedFetchingHtmlDocument(error: Error)
    case failedToParseHtmlDocument(error: Error)
    case invalidHost(error: Error)
    case invalidMimeType(error: Error)
    case noNetworkConnection
    case responseError(error: Error)
    case unknownError(error: Error)
    
    var cancelled: Bool {
        switch self {
        case .cancelled:
            return true
        default:
            return false
        }
    }
    
    var networkFailed: Bool {
        switch self {
        case .noNetworkConnection:
            return true
        default:
            return false
        }
    }
    
    var unknownError: Bool {
        switch self {
        case .unknownError( _):
            return true
        default:
            return false
        }
    }
}
