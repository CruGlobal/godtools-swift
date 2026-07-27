//
//  Array+Error.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension Array where Element == Error {
    
    var containsNetworkFailed: Bool {
        return firstErrorNotConnectedToInternet != nil
    }
    
    var firstErrorNotConnectedToInternet: Error? {
        for error in self {
            if error.isUrlErrorNotConnectedToInternetCode {
                return error
            }
        }
        return nil
    }
}
