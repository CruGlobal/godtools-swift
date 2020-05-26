//
//  Error+NetworkErrors.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension Error {
    
    private var errorCode: Int {
        return (self as NSError).code
    }
    
    #if os(iOS)
    var requestCancelled: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    var notConnectedToInternet: Bool {
        return errorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
    #endif
}
