//
//  WebArchiveOperationError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct WebArchiveOperationError: Error {
    
    enum Reason {
        case failedEncodingPlistData
        case failedFetchingHtmlDocument
        case noNetworkConnection
        case operationCancelled
    }
    
    let url: URL
    let error: Error
    let reason: WebArchiveOperationError.Reason
}
