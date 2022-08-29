//
//  Error+NetworkError.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Error {
    
    var requestErrorCode: Int {
        return (self as NSError).code
    }
    
    var requestCancelled: Bool {
        return requestErrorCode == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    
    var notConnectedToInternet: Bool {
        return requestErrorCode == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
}
