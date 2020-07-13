//
//  ArticleAemImportOperationError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticleAemImportOperationError: Error {
    
    case cancelled
    case failedToParseJson(error: ArticleAemImportDataParserError)
    case failedToSerializeJson(error: Error)
    case invalidAemImportJsonUrl
    case invalidAemImportSrcUrl
    case noNetworkConnection
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
