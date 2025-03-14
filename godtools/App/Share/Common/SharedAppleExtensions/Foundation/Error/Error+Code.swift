//
//  Error+Code.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 3/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension Error {
    
    var code: Int {
        return (self as NSError).code
    }
    
    var isUrlErrorCancelledCode: Bool {
        return code == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    
    var isUrlErrorNotConnectedToInternetCode: Bool {
        return code == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
    
    var isNetworkConnectionLost: Bool {
        return code == Int(CFNetworkErrors.cfErrorHTTPConnectionLost.rawValue) || code == Int(CFNetworkErrors.cfurlErrorNetworkConnectionLost.rawValue)
    }
    
    var isUserCancelled: Bool {
        return code == NSUserCancelledError
    }
}
