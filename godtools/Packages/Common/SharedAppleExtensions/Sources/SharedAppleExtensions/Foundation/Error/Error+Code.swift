//
//  Error+Code.swift
//  SharedAppleExtensions
//
//  Created by Levi Eggert on 3/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

public extension Error {
    
    var code: Int {
        return (self as NSError).code
    }
    
    var isUrlErrorCancelledCode: Bool {
        return code == Int(CFNetworkErrors.cfurlErrorCancelled.rawValue)
    }
    
    var isUrlErrorNotConnectedToInternetCode: Bool {
        return code == Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
    }
}
